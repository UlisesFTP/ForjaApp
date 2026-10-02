import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/notification_service.dart';
import '../../core/widgets.dart';
import '../view_models/settings_view_model.dart';

Future<void> showReminder(BuildContext context, SettingsViewModel vm) =>
    showForjaSheet<void>(
      context,
      title: 'Recordatorios',
      child: _ReminderForm(vm),
    );

class _ReminderForm extends StatefulWidget {
  const _ReminderForm(this.vm);
  final SettingsViewModel vm;
  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  late bool enabled;
  late TimeOfDay time;
  @override
  void initState() {
    super.initState();
    final r = widget.vm.reminder;
    enabled = r.enabled;
    time = TimeOfDay(hour: r.hour, minute: r.minute);
    // The system permission may have changed since the last look.
    widget.vm.refreshReminders();
  }

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final vm = widget.vm, status = vm.reminderStatus;
      final saved = vm.reminder;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Recordar días de gimnasio'),
            value: enabled,
            onChanged: vm.busy
                ? null
                : (value) => setState(() => enabled = value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Hora preferida'),
            trailing: Text(time.format(context)),
            onTap: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (selected != null && mounted) setState(() => time = selected);
            },
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado en este teléfono',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Semantics(
                  liveRegion: true,
                  child: Text(switch (status.permission) {
                    NotificationPermission.granted =>
                      'Permiso del sistema: permitido.',
                    NotificationPermission.denied => 'Permiso del sistema: denegado. Sin él no llegará ningún aviso.',
                    NotificationPermission.unknown =>
                      'Permiso del sistema: sin comprobar todavía.',
                  }, key: const ValueKey('permission-state')),
                ),
                Text(
                  saved.enabled
                      ? status.scheduled == 0
                            ? 'Programados: ninguno ahora mismo.'
                            : 'Programados: ${status.scheduled}${status.next == null ? '' : ' · próximo ${friendlyDate(status.next!)} a las ${TimeOfDay.fromDateTime(status.next!).format(context)}'}.'
                      : 'Los recordatorios están desactivados.',
                  key: const ValueKey('scheduled-state'),
                ),
                if (status.error != null)
                  Text(status.error!, key: const ValueKey('reminder-error')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Android reports "denied" before it was ever asked, so the
                    // request is offered whenever permission is missing; the
                    // system page is offered too once it was refused.
                    if (status.permission != NotificationPermission.granted)
                      OutlinedButton(
                        key: const ValueKey('ask-permission'),
                        onPressed: vm.busy ? null : vm.askPermission,
                        child: const Text('Permitir avisos'),
                      ),
                    if (status.permission == NotificationPermission.denied)
                      OutlinedButton(
                        key: const ValueKey('open-settings'),
                        onPressed: vm.openSystemSettings,
                        child: const Text('Abrir ajustes del teléfono'),
                      ),
                    if (status.permission == NotificationPermission.granted)
                      OutlinedButton(
                        key: const ValueKey('send-test'),
                        onPressed: vm.busy ? null : vm.sendTest,
                        child: const Text('Enviar aviso de prueba'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Se programan los próximos 28 días de entrenamiento y se renuevan cada vez que abres la app. Son avisos locales, sin Internet. El sistema puede retrasarlos unos minutos: no hay garantía de puntualidad exacta.',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: vm.busy
                ? null
                : () async {
                    if (await vm.save(
                          ReminderSettings(
                            enabled: enabled,
                            hour: time.hour,
                            minute: time.minute,
                          ),
                        ) &&
                        context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            child: Text(vm.busy ? 'Guardando…' : 'Guardar preferencia'),
          ),
          if (vm.error != null) Text(vm.error!),
        ],
      );
    },
  );
}
