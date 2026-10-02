import 'package:flutter/material.dart';

import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/settings_view_model.dart';

Future<void> showUnits(BuildContext context, SettingsViewModel vm) =>
    showForjaSheet<void>(
      context,
      title: 'Unidad de peso',
      child: _UnitForm(vm),
    );

class _UnitForm extends StatelessWidget {
  const _UnitForm(this.vm);
  final SettingsViewModel vm;
  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<WeightUnit>(
          segments: const [
            ButtonSegment(value: WeightUnit.kg, label: Text('Kilogramos (kg)')),
            ButtonSegment(value: WeightUnit.lb, label: Text('Libras (lb)')),
          ],
          selected: {vm.unit},
          onSelectionChanged: vm.busy
              ? null
              : (value) => vm.saveUnit(value.first),
        ),
        const SizedBox(height: 16),
        const SurfaceCard(
          child: Text(
            'Solo cambia cómo ves y escribes los pesos. Tus registros se guardan siempre en kilogramos y no se redondean, así que cambiar de unidad no los altera.',
          ),
        ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    ),
  );
}
