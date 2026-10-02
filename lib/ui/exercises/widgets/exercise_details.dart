import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../../data/services/tutorial_launcher.dart';
import '../../core/widgets.dart';

/// [alternativesOf] lists compatible substitutes; tapping one opens its own
/// details. Omit it where the person's equipment is not at hand.
Future<void> showExerciseDetails(
  BuildContext context,
  Exercise exercise,
  TutorialLauncher launcher, {
  List<Exercise> Function(Exercise)? alternativesOf,
}) => showForjaSheet<void>(
  context,
  title: exercise.name,
  child: ExerciseDetails(
    exercise: exercise,
    launcher: launcher,
    alternativesOf: alternativesOf,
  ),
);

class ExerciseDetails extends StatefulWidget {
  const ExerciseDetails({
    super.key,
    required this.exercise,
    required this.launcher,
    this.alternativesOf,
  });
  final Exercise exercise;
  final TutorialLauncher launcher;
  final List<Exercise> Function(Exercise)? alternativesOf;
  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  // The link that failed to open, so it can be retried or copied.
  Uri? failed;
  bool copied = false;

  Future<void> _open(Uri uri) async {
    final opened = await widget.launcher.open(uri);
    if (mounted) {
      setState(() {
        failed = opened ? null : uri;
        copied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final direct = e.tutorial;
    final alternatives = widget.alternativesOf?.call(e) ?? const <Exercise>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${e.group.toUpperCase()} · ${equipmentLabels[e.equipment]!.toUpperCase()}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(e.description),
        const SizedBox(height: 20),
        _section(context, 'Músculos', e.muscles),
        if (e.warmup.isNotEmpty) _section(context, 'Calentamiento', e.warmup),
        if (e.tip.isNotEmpty) _section(context, 'Técnica', e.tip),
        if (!e.archived)
          _section(
            context,
            'Prescripción por defecto',
            '${e.sets} series × ${e.reps}${e.loadType == LoadType.time ? '' : ' repeticiones'} · RIR ${e.rir} · descanso ${e.restSeconds} s',
          ),
        if (alternatives.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alternativas con tu equipo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final alt in alternatives)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(alt.name),
                    subtitle: Text(
                      '${alt.muscles} · ${equipmentLabels[alt.equipment]}',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pop(context);
                      showExerciseDetails(
                        context,
                        alt,
                        widget.launcher,
                        alternativesOf: widget.alternativesOf,
                      );
                    },
                  ),
              ],
            ),
          ),
        const Text(
          'RIR = repeticiones en reserva. RIR 2 significa terminar la serie pudiendo hacer unas dos repeticiones más.',
        ),
        if (!e.archived) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(
              direct != null
                  ? 'Ver tutorial en YouTube'
                  : 'Buscar tutorial en YouTube',
            ),
            onPressed: () => _open(direct ?? e.tutorialUri),
          ),
          const SizedBox(height: 8),
          Text(
            direct != null
                ? 'Enlace revisado a un vídeo de YouTube; requiere conexión.'
                : 'Se abre una búsqueda de técnica y Shorts; no es un video seleccionado.',
          ),
        ],
        if (failed != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: const Text('No se pudo abrir YouTube. Revisa la conexión.'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _open(failed!),
                child: const Text('Reintentar'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: failed.toString()),
                  );
                  if (mounted) setState(() => copied = true);
                },
                child: Text(copied ? 'Enlace copiado' : 'Copiar enlace'),
              ),
              if (direct != null && failed == direct)
                OutlinedButton(
                  onPressed: () => _open(e.tutorialUri),
                  child: const Text('Buscar en YouTube'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _section(BuildContext context, String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(value),
      ],
    ),
  );
}
