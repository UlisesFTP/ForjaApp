import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../core/widgets.dart';
import '../view_models/data_view_model.dart';

Future<void> showData(
  BuildContext context,
  DataViewModel vm, {
  VoidCallback? onReset,
}) => showForjaSheet<void>(
  context,
  title: 'Datos y privacidad',
  child: DataPanel(vm: vm, onReset: onReset),
);

// (singular, plural): "1 sesión", never "1 sesiones".
const _countLabels = {
  'sessions': ('sesión', 'sesiones'),
  'sets': ('serie registrada', 'series registradas'),
  'food': ('alimento', 'alimentos'),
  'recipes': ('receta', 'recetas'),
  'plans': ('versión de plan', 'versiones de plan'),
  'cardio': ('sesión de cardio', 'sesiones de cardio'),
  'reviews': ('revisión', 'revisiones'),
  'profileHistory': ('respuesta del perfil', 'respuestas del perfil'),
};

class DataPanel extends StatelessWidget {
  const DataPanel({super.key, required this.vm, this.onReset});
  final DataViewModel vm;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) {
      final preview = vm.preview;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SurfaceCard(
            child: Text(
              'Tus datos viven solo en este teléfono, en una carpeta privada de la app. FORJA no usa cuenta, no envía nada por Internet y no hace copias automáticas. La base de datos no está cifrada: protege el teléfono con su bloqueo.',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Copia de seguridad',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Un archivo con todo (perfil, planes, sesiones, series, cardio, nutrición). Tú eliges dónde se guarda. Contiene datos personales y no está cifrado: el código de comprobación detecta daños, no protege el contenido.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('export-copy'),
            onPressed: vm.busy ? null : () => _export(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Exportar copia'),
          ),
          if (vm.exportNotice != null)
            _Notice(vm.exportNotice!, 'export-notice'),
          const SizedBox(height: 20),
          Text('Importar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          const Text(
            'Importar reemplaza todos tus datos actuales por los del archivo. Antes de reemplazar, la app guarda una copia de lo que tienes en su carpeta privada; si algo falla, no se cambia nada.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('import-copy'),
            onPressed: vm.busy ? null : vm.pickBackup,
            icon: const Icon(Icons.download),
            label: const Text('Elegir archivo…'),
          ),
          if (vm.importNotice != null)
            _Notice(vm.importNotice!, 'import-notice'),
          if (vm.refusal != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.refusal!, key: const ValueKey('import-refusal')),
                      for (final issue in vm.issues.take(3))
                        Text('• $issue', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          if (preview != null) ...[
            const SizedBox(height: 12),
            SurfaceCard(
              key: const ValueKey('import-preview'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.pickedName ?? 'Copia de seguridad',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Creada el ${friendlyDate(preview.createdAt.toLocal())}',
                  ),
                  const SizedBox(height: 6),
                  for (final e in _countLabels.entries)
                    if ((preview.counts[e.key] ?? 0) > 0)
                      Text(
                        '${preview.counts[e.key]} '
                        '${preview.counts[e.key] == 1 ? e.value.$1 : e.value.$2}',
                      ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se reemplazarán TODOS tus datos actuales.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('import-confirm'),
              onPressed: vm.busy ? null : vm.confirmImport,
              child: Text(vm.busy ? 'Importando…' : 'Reemplazar mis datos'),
            ),
            TextButton(
              key: const ValueKey('import-cancel'),
              onPressed: vm.busy ? null : vm.cancelImport,
              child: const Text('Cancelar'),
            ),
          ],
          const SizedBox(height: 20),
          Text('Eliminar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          const Text(
            'Borra todo lo que guardaste y cancela los recordatorios; la app vuelve a empezar. No se puede deshacer: exporta una copia antes si quieres conservarlo.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('delete-all'),
            onPressed: vm.busy ? null : () => _delete(context),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Eliminar todos mis datos'),
          ),
          if (vm.error != null)
            Semantics(liveRegion: true, child: Text(vm.error!)),
        ],
      );
    },
  );

  Future<void> _export(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar copia'),
        content: const Text(
          'El archivo contiene tus datos personales (perfil, notas, registros) sin cifrar. Guárdalo solo donde confíes. Elegirás dónde se guarda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('export-continue'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elegir destino'),
          ),
        ],
      ),
    );
    if (ok == true) await vm.exportCopy();
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteDialog(),
    );
    if (confirmed == true && await vm.deleteEverything() && context.mounted) {
      Navigator.pop(context);
      onReset?.call();
    }
  }
}

/// What just happened, inside the panel and announced to screen readers.
class _Notice extends StatelessWidget {
  const _Notice(this.text, String id) : _id = id;
  final String text;
  final String _id;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SurfaceCard(child: Text(text, key: ValueKey(_id))),
    ),
  );
}

/// Asks the person to type BORRAR. The controller lives with the dialog, so it
/// is disposed only after the dialog has finished closing.
class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog();
  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('¿Eliminar todos tus datos?'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Se borran el perfil, los planes, las sesiones, el cardio, la nutrición y las copias previas de la app. No se puede deshacer. Escribe BORRAR para confirmar.',
          ),
          TextField(
            key: const ValueKey('delete-confirm-text'),
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'BORRAR'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const ValueKey('delete-confirm'),
        onPressed: controller.text.trim() == 'BORRAR'
            ? () => Navigator.pop(context, true)
            : null,
        child: const Text('Eliminar todo'),
      ),
    ],
  );
}
