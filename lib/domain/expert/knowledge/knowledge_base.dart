import '../engine/rule.dart';
import 'rules/adherence_rules.dart';
import 'rules/cardio_rules.dart';
import 'rules/logging_rules.dart';
import 'rules/nutrition_rules.dart';
import 'rules/plan_rules.dart';
import 'rules/progression_rules.dart';
import 'rules/readiness_rules.dart';
import 'rules/safety_rules.dart';

/// The rules of `expert-v1`. Ids are unique (checked by a test) and stored
/// with every decision, so a rule is never renamed: a changed rule gets a
/// new id or a new knowledge-base version.
const List<ExpertRule> knowledgeBaseV1 = [
  // Safety (S1–S7).
  InjuryToday(),
  InjuryRecent(),
  ReviewPain(),
  ReturnAfterBreak(),
  PainPersists(),
  MinorNoRanges(),
  LowCalorieGoal(),
  // Readiness and fatigue (R1, D1).
  LighterSession(),
  DeloadSuggestion(),
  // Progression (P1–P4).
  ProgressionRules(),
  BigStep(),
  BodyweightReps(),
  Stall(),
  // Plan and volume (V2–V4, G1–G4).
  LowVolume(),
  HighVolume(),
  Frequency(),
  RoutineTooLong(),
  MissingEquipment(),
  DraftPending(),
  ExampleAdapted(),
  // Adherence (A1, A2).
  Unrecorded(),
  LowAdherence(),
  // Cardio (C1, C2).
  WhoWeek(),
  CardioProgress(),
  // Nutrition (N1–N4).
  AveragesVsGoals(),
  UnloggedDays(),
  MacroCoverage(),
  ProteinReference(),
  // Logging (L1, L2).
  MissingEffort(),
  DoneWithoutSets(),
];

ExpertRule? ruleById(String id) {
  for (final r in knowledgeBaseV1) {
    if (r.id == id) return r;
  }
  return null;
}
