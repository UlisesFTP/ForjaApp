import '../../../data/services/reminder_coordinator.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/notification_service.dart';
import '../../../domain/repositories/repositories.dart';
import '../../core/view_model.dart';

class SettingsViewModel extends ViewModel {
  SettingsViewModel(this._repository, this._profiles, this._reminders) {
    watch(_repository);
    watch(_profiles);
    watch(_reminders);
  }
  final ReminderCoordinator _reminders;

  /// What the system says, apart from what the person wants.
  ReminderStatus get reminderStatus => _reminders.status;
  NotificationPermission get permission => _reminders.status.permission;

  /// Looks at the system permission and the scheduled reminders again.
  Future<void> refreshReminders() => _reminders.reconcile();

  Future<bool> askPermission() => run(() async {
    final result = await _reminders.requestPermission();
    announce(switch (result) {
      NotificationPermission.granted => 'Avisos permitidos',
      NotificationPermission.denied => 'El sistema no permite avisos. Puedes cambiarlo en los ajustes del teléfono.',
      NotificationPermission.unknown => 'No se pudo comprobar el permiso',
    });
  });

  Future<void> openSystemSettings() => _reminders.openSystemSettings();

  Future<bool> sendTest() => run(() async {
    await _reminders.sendTest();
    announce('Aviso de prueba enviado');
  });
  final SettingsRepository _repository;
  final ProfileRepository _profiles;
  WeightUnit get unit => _profiles.profile.unit;

  /// Only changes how weights are shown and typed; stored kilograms are
  /// never rewritten.
  Future<bool> saveUnit(WeightUnit value) => run(
    () => _profiles.saveProfile(_profiles.profile.copyWith(unit: value)),
    success: value == WeightUnit.kg
        ? 'Los pesos se muestran en kg'
        : 'Los pesos se muestran en lb',
  );
  ReminderSettings get reminder => _repository.reminder;

  /// Saves the wish. Turning it on also asks the system for permission, but
  /// the wish is kept either way: the screen then says what the system
  /// allows.
  Future<bool> save(ReminderSettings value) => run(() async {
    await _repository.saveReminder(value);
    if (value.enabled && permission != NotificationPermission.granted) {
      await _reminders.requestPermission();
    }
    // The coordinator also reacts to the saved change; wait for it so the
    // message reflects what is really scheduled.
    await _reminders.reconcile();
    final status = _reminders.status;
    announce(
      !value.enabled
          ? 'Recordatorios desactivados'
          : status.permission == NotificationPermission.denied
          ? 'Preferencia guardada. El sistema no permite avisos todavía.'
          : status.scheduled > 0
          ? 'Recordatorios programados: ${status.scheduled}'
          : 'Preferencia guardada',
    );
  });
}
