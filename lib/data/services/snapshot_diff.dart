import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/models/models.dart';

/// Rows to write so storage moves from one committed snapshot to the next.
/// Immutable models are compared by identity: `copyWith` reuses untouched
/// values, so a false positive only rewrites one row.
class SnapshotChanges {
  const SnapshotChanges({
    this.profile,
    this.reminder,
    this.sessions = const {},
    this.removedSessions = const {},
    this.overrides = const {},
    this.removedOverrides = const {},
    this.checkIns = const {},
    this.removedCheckIns = const {},
    this.addedFood = const [],
    this.updatedFood = const [],
    this.removedFood = const {},
    this.plans = const [],
    this.profileAnswers = const [],
    this.afterCheckIns = const {},
    this.removedAfterCheckIns = const {},
    this.adjustments = const {},
    this.removedAdjustments = const {},
    this.reschedules = const [],
    this.sessionEvents = const [],
    this.progressionDecisions = const [],
    this.reviews = const [],
    this.cardio = const [],
    this.removedCardio = const {},
    this.favorites = const [],
    this.removedFavorites = const {},
    this.recipes = const [],
    this.removedRecipes = const {},
    this.goals,
    this.coachDecisions = const [],
    this.coachPreferences = const [],
  });

  /// Everything in [snapshot] as new rows, used by the legacy import.
  SnapshotChanges.insertAll(AppSnapshot snapshot)
    : this(
        profile: snapshot.profile,
        reminder: snapshot.reminder,
        sessions: snapshot.sessions,
        overrides: snapshot.overrides,
        checkIns: snapshot.checkIns,
        addedFood: snapshot.food,
        plans: snapshot.plans,
        profileAnswers: snapshot.profileHistory,
        afterCheckIns: snapshot.afterCheckIns,
        adjustments: snapshot.adjustments,
        reschedules: snapshot.reschedules,
        sessionEvents: snapshot.sessionEvents,
        progressionDecisions: snapshot.progressionDecisions,
        reviews: snapshot.reviews,
        cardio: snapshot.cardio,
        favorites: snapshot.favorites,
        recipes: snapshot.recipes,
        goals: snapshot.goals.isEmpty ? null : snapshot.goals,
        coachDecisions: snapshot.coachDecisions,
        coachPreferences: snapshot.coachPreferences,
      );

  final UserProfile? profile;
  final ReminderSettings? reminder;
  // Keyed by calendar date key.
  final Map<String, WorkoutSession> sessions;
  final Set<String> removedSessions;
  // A null value is an explicit rest day, so it is a change like any other.
  final Map<String, String?> overrides;
  final Set<String> removedOverrides;
  final Map<String, CheckIn> checkIns;
  final Set<String> removedCheckIns;
  final List<FoodEntry> addedFood, updatedFood;
  final Set<String> removedFood;
  // Plan versions that are new or changed; versions are never deleted.
  final List<PlanVersion> plans;
  // New entries of the append-only answer history.
  final List<ProfileAnswer> profileAnswers;
  final Map<String, CheckIn> afterCheckIns;
  final Set<String> removedAfterCheckIns;
  final Map<String, bool> adjustments;
  final Set<String> removedAdjustments;
  // Rescheduling entries that are new or were undone (never deleted).
  final List<Reschedule> reschedules;
  // New entries of the append-only session audit trail.
  final List<SessionEvent> sessionEvents;
  // New entries of two append-only logs.
  final List<ProgressionDecision> progressionDecisions;
  final List<MonthlyReview> reviews;
  // Cardio sessions that are new or changed (the active one changes often),
  // and ids of those discarded.
  final List<CardioSession> cardio;
  final Set<String> removedCardio;
  // Saved foods and recipes that are new or changed, and ids that were removed.
  final List<FavoriteFood> favorites;
  final Set<String> removedFavorites;
  final List<Recipe> recipes;
  final Set<String> removedRecipes;
  final NutritionGoals? goals;
  // New entries of the append-only coach log, and preferences that are new
  // or changed (keyed by family; never removed one by one).
  final List<CoachDecision> coachDecisions;
  final List<CoachPreference> coachPreferences;

  bool get isEmpty =>
      profile == null &&
      reminder == null &&
      sessions.isEmpty &&
      removedSessions.isEmpty &&
      overrides.isEmpty &&
      removedOverrides.isEmpty &&
      checkIns.isEmpty &&
      removedCheckIns.isEmpty &&
      addedFood.isEmpty &&
      updatedFood.isEmpty &&
      removedFood.isEmpty &&
      plans.isEmpty &&
      profileAnswers.isEmpty &&
      afterCheckIns.isEmpty &&
      removedAfterCheckIns.isEmpty &&
      adjustments.isEmpty &&
      removedAdjustments.isEmpty &&
      reschedules.isEmpty &&
      sessionEvents.isEmpty &&
      progressionDecisions.isEmpty &&
      reviews.isEmpty &&
      cardio.isEmpty &&
      removedCardio.isEmpty &&
      favorites.isEmpty &&
      removedFavorites.isEmpty &&
      recipes.isEmpty &&
      removedRecipes.isEmpty &&
      goals == null &&
      coachDecisions.isEmpty &&
      coachPreferences.isEmpty;
}

SnapshotChanges diffSnapshots(AppSnapshot previous, AppSnapshot next) {
  Map<String, T> changed<T>(Map<String, T> before, Map<String, T> after) => {
    for (final e in after.entries)
      if (!before.containsKey(e.key) || !identical(before[e.key], e.value))
        e.key: e.value,
  };
  Set<String> removed<T>(Map<String, T> before, Map<String, T> after) =>
      before.keys.where((key) => !after.containsKey(key)).toSet();

  final overrides = {
    for (final e in next.overrides.entries)
      if (!previous.overrides.containsKey(e.key) ||
          previous.overrides[e.key] != e.value)
        e.key: e.value,
  };
  final before = {for (final f in previous.food) f.id: f};
  final after = {for (final f in next.food) f.id: f};
  // Food is append/remove only; the stored sequence is the list order.
  final keptBefore = previous.food.map((f) => f.id).where(after.containsKey);
  final keptAfter = next.food.map((f) => f.id).where(before.containsKey);
  if (!listEquals(keptBefore.toList(), keptAfter.toList())) {
    throw StateError('Reordering food entries is not supported by the store.');
  }
  // Plan versions keep their creation order and are never removed; a draft
  // may be replaced in place. The answer history only grows.
  final planIds = previous.plans.map((p) => p.id).toList();
  if (!listEquals(
    planIds,
    next.plans.map((p) => p.id).take(planIds.length).toList(),
  )) {
    throw StateError('Plan versions cannot be removed or reordered.');
  }
  final beforePlans = {for (final p in previous.plans) p.id: p};
  final answers = previous.profileHistory;
  if (next.profileHistory.length < answers.length ||
      !Iterable<int>.generate(answers.length)
          .every((i) => identical(answers[i], next.profileHistory[i]))) {
    throw StateError('The profile answer history can only grow.');
  }
  // Reschedules and session events only grow; an undo replaces the entry.
  final moves = previous.reschedules;
  if (next.reschedules.length < moves.length ||
      !Iterable<int>.generate(moves.length)
          .every((i) => next.reschedules[i].id == moves[i].id)) {
    throw StateError('Reschedules cannot be removed or reordered.');
  }
  final events = previous.sessionEvents;
  if (next.sessionEvents.length < events.length ||
      !Iterable<int>.generate(events.length)
          .every((i) => identical(events[i], next.sessionEvents[i]))) {
    throw StateError('The session audit trail can only grow.');
  }
  final decided = previous.progressionDecisions;
  if (next.progressionDecisions.length < decided.length ||
      !Iterable<int>.generate(decided.length)
          .every((i) => identical(decided[i], next.progressionDecisions[i]))) {
    throw StateError('Progression decisions can only be appended.');
  }
  final reviewed = previous.reviews;
  if (next.reviews.length < reviewed.length ||
      !Iterable<int>.generate(reviewed.length)
          .every((i) => identical(reviewed[i], next.reviews[i]))) {
    throw StateError('Monthly reviews can only be appended.');
  }
  final coached = previous.coachDecisions;
  if (next.coachDecisions.length < coached.length ||
      !Iterable<int>.generate(coached.length)
          .every((i) => identical(coached[i], next.coachDecisions[i]))) {
    throw StateError('Coach decisions can only be appended.');
  }
  final beforePreferences = {
    for (final p in previous.coachPreferences) p.family: p,
  };
  final afterPreferences = {for (final p in next.coachPreferences) p.family};
  if (!afterPreferences.containsAll(beforePreferences.keys)) {
    throw StateError('Coach preferences are never removed one by one.');
  }
  final beforeCardio = {for (final c in previous.cardio) c.id: c};
  final afterCardio = {for (final c in next.cardio) c.id: c};
  // Existing sessions keep their creation order; new ones come last.
  final keptOrder = previous.cardio
      .map((c) => c.id)
      .where(afterCardio.containsKey)
      .toList();
  final nextOrder = next.cardio
      .map((c) => c.id)
      .where(beforeCardio.containsKey)
      .toList();
  if (!listEquals(keptOrder, nextOrder)) {
    throw StateError('Cardio sessions cannot be reordered.');
  }
  final beforeFavorites = {for (final f in previous.favorites) f.id: f};
  final afterFavorites = {for (final f in next.favorites) f.id: f};
  final beforeRecipes = {for (final r in previous.recipes) r.id: r};
  final afterRecipes = {for (final r in next.recipes) r.id: r};
  // Saved items keep the order they were created in; new ones come last.
  for (final (before, after) in [
    (
      previous.favorites.map((f) => f.id).where(afterFavorites.containsKey),
      next.favorites.map((f) => f.id).where(beforeFavorites.containsKey),
    ),
    (
      previous.recipes.map((r) => r.id).where(afterRecipes.containsKey),
      next.recipes.map((r) => r.id).where(beforeRecipes.containsKey),
    ),
  ]) {
    if (!listEquals(before.toList(), after.toList())) {
      throw StateError('Saved foods and recipes cannot be reordered.');
    }
  }
  return SnapshotChanges(
    coachDecisions: next.coachDecisions.sublist(coached.length),
    coachPreferences: [
      for (final p in next.coachPreferences)
        if (!identical(beforePreferences[p.family], p)) p,
    ],
    favorites: [
      for (final f in next.favorites)
        if (!identical(beforeFavorites[f.id], f)) f,
    ],
    removedFavorites: beforeFavorites.keys
        .where((id) => !afterFavorites.containsKey(id))
        .toSet(),
    recipes: [
      for (final r in next.recipes)
        if (!identical(beforeRecipes[r.id], r)) r,
    ],
    removedRecipes: beforeRecipes.keys
        .where((id) => !afterRecipes.containsKey(id))
        .toSet(),
    goals: identical(previous.goals, next.goals) ? null : next.goals,
    cardio: [
      for (final c in next.cardio)
        if (!identical(beforeCardio[c.id], c)) c,
    ],
    removedCardio: beforeCardio.keys
        .where((id) => !afterCardio.containsKey(id))
        .toSet(),
    progressionDecisions: next.progressionDecisions.sublist(decided.length),
    reviews: next.reviews.sublist(reviewed.length),
    reschedules: [
      for (var i = 0; i < next.reschedules.length; i++)
        if (i >= moves.length || !identical(moves[i], next.reschedules[i]))
          next.reschedules[i],
    ],
    sessionEvents: next.sessionEvents.sublist(events.length),
    afterCheckIns: changed(previous.afterCheckIns, next.afterCheckIns),
    removedAfterCheckIns: removed(previous.afterCheckIns, next.afterCheckIns),
    adjustments: {
      for (final e in next.adjustments.entries)
        if (previous.adjustments[e.key] != e.value ||
            !previous.adjustments.containsKey(e.key))
          e.key: e.value,
    },
    removedAdjustments: removed(previous.adjustments, next.adjustments),
    plans: [
      for (final p in next.plans)
        if (!identical(beforePlans[p.id], p)) p,
    ],
    profileAnswers: next.profileHistory.sublist(answers.length),
    profile: identical(previous.profile, next.profile) ? null : next.profile,
    reminder: identical(previous.reminder, next.reminder)
        ? null
        : next.reminder,
    sessions: changed(previous.sessions, next.sessions),
    removedSessions: removed(previous.sessions, next.sessions),
    overrides: overrides,
    removedOverrides: removed(previous.overrides, next.overrides),
    checkIns: changed(previous.checkIns, next.checkIns),
    removedCheckIns: removed(previous.checkIns, next.checkIns),
    addedFood: next.food.where((f) => !before.containsKey(f.id)).toList(),
    updatedFood: next.food
        .where((f) => before.containsKey(f.id) && !identical(before[f.id], f))
        .toList(),
    removedFood: before.keys.where((id) => !after.containsKey(id)).toSet(),
  );
}

/// Structural equality of two snapshots, ignoring map insertion order.
bool sameSnapshotContent(AppSnapshot a, AppSnapshot b) =>
    canonicalJson(a.toJson()) == canonicalJson(b.toJson());

/// JSON text with map keys sorted, so equal content compares equal.
String canonicalJson(Object? value) => jsonEncode(_sorted(value));
Object? _sorted(Object? value) => switch (value) {
  Map() => {
    for (final key in value.keys.cast<String>().toList()..sort())
      key: _sorted(value[key]),
  },
  List() => value.map(_sorted).toList(),
  _ => value,
};
