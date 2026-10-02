import 'package:flutter/material.dart';

import '../../../data/services/tutorial_launcher.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/exercises_view_model.dart';
import 'exercise_details.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({super.key, required this.vm, required this.launcher});
  final ExercisesViewModel vm;
  final TutorialLauncher launcher;
  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final results = vm.filtered;
      return ResponsivePage(
        header: const PageHeading(
          'EJERCICIOS',
          subtitle: 'Conoce el movimiento. Entrena con intención.',
        ),
        primary: [
          TextField(
            controller: search,
            onChanged: vm.search,
            decoration: InputDecoration(
              labelText: 'Buscar ejercicio o músculo',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        search.clear();
                        vm.search('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final category in vm.categories)
                ChoiceChip(
                  label: Text(category),
                  selected: category == vm.category,
                  onSelected: (_) => vm.filter(category),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in Equipment.values)
                FilterChip(
                  label: Text(equipmentLabels[e]!),
                  selected: vm.equipmentFilter == e,
                  onSelected: (on) => vm.filterEquipment(on ? e : null),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Solo mi equipo'),
            value: vm.onlyMyEquipment,
            onChanged: vm.toggleMyEquipment,
          ),
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(
              '${results.length} ejercicio${results.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              title: 'Sin resultados',
              message: 'Prueba con otro músculo, ejercicio o equipo.',
            ),
          // One column on a phone; more as the screen allows.
          ResponsiveGrid(
            children: [
              for (final exercise in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.group} · ${exercise.muscles} · ${equipmentLabels[exercise.equipment]}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => showExerciseDetails(
                        context,
                        exercise,
                        widget.launcher,
                        alternativesOf: vm.alternatives,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}
