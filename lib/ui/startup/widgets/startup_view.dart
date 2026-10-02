import 'package:flutter/material.dart';

import '../../../domain/models/storage_failure.dart';
import '../../core/widgets.dart';
import '../view_models/startup_view_model.dart';

class StartupView extends StatelessWidget {
  const StartupView({super.key, required this.vm});
  final StartupViewModel vm;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: VmObserver(
        viewModel: vm,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/forja-icon.png',
                    width: 64,
                    height: 64,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 20),
                  if (vm.failure case final failure?)
                    ..._failed(context, failure)
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: 'Abriendo tus registros',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _failed(BuildContext context, StorageFailure failure) {
    final (title, body) = switch (failure) {
      LegacyDataRejected() => (
        'No pudimos importar tus registros',
        'Algunos datos guardados por la versión anterior no pasaron la validación. No se ha borrado ni cambiado nada.',
      ),
      LegacyFutureVersion() => (
        'Tus registros son de una versión más nueva',
        'Se guardaron con una versión de FORJA más reciente que esta. Actualiza la app para abrirlos. No se ha borrado ni cambiado nada.',
      ),
      DatabaseNewerThanApp() => (
        'Esta versión es más antigua que tus datos',
        'Tus registros pertenecen a una versión más reciente de FORJA. Actualiza la app para abrirlos. No se ha borrado ni cambiado nada.',
      ),
      StorageUnavailable() => (
        'No pudimos abrir FORJA',
        'No se pudieron leer tus registros. No se han borrado.',
      ),
    };
    return [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      const SizedBox(height: 8),
      Text(body, style: Theme.of(context).textTheme.bodyLarge),
      if (failure case LegacyDataRejected(:final issues)) ...[
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qué falló', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final issue in issues) Text(issue),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      FilledButton(
        onPressed: vm.busy ? null : vm.open,
        child: const Text('Reintentar'),
      ),
      if (failure.originalData != null) ...[
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: vm.busy ? null : vm.copyOriginal,
          icon: const Icon(Icons.copy),
          label: const Text('Copiar datos originales'),
        ),
        const SizedBox(height: 8),
        Text(
          'Incluyen tu perfil y tus notas. Pégalos solo donde confíes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
      if (failure.canSkipImport) ...[
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: vm.busy ? null : () => _confirmSkip(context),
          child: const Text('Continuar sin importar'),
        ),
      ],
      if (vm.error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(liveRegion: true, child: Text(vm.error!)),
        ),
    ];
  }

  Future<void> _confirmSkip(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Continuar sin importar?'),
        content: const Text(
          'FORJA empezará sin tus registros anteriores. Los datos originales no se borran y siguen en este teléfono, pero esta versión no volverá a intentar importarlos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar sin importar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await vm.continueWithoutImport();
  }
}
