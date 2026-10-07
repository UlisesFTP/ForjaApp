import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/expert/expert_coach.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/coach_advice_view_model.dart';
import '../../core/tone_buttons.dart';

/// What the page needs from the rest of the app to carry out an action: it
/// navigates or opens an existing sheet. Nothing is saved by the page.
typedef CoachActionHandler = Future<void> Function(
  BuildContext context,
  CoachAction action,
);

/// Opens the Coach page with a fresh [vm], released when the page closes.
Future<void> showCoachPage(
  BuildContext context, {
  required CoachAdviceViewModel vm,
  required CoachActionHandler onAction,
  required VoidCallback onProfile,
  RuleFamily? only,
  Widget? extra,
}) async {
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoachPage(
          vm: vm,
          onAction: onAction,
          onProfile: onProfile,
          only: only,
          extra: extra,
        ),
      ),
    );
  } finally {
    vm.dispose();
  }
}

const _kindLabels = {
  RecommendationKind.suggestion: 'Sugerencia',
  RecommendationKind.caution: 'Atención',
  RecommendationKind.info: 'Para tu información',
  RecommendationKind.blocked: 'Sin aumento',
};

const _kindIcons = {
  RecommendationKind.suggestion: Icons.lightbulb_outline,
  RecommendationKind.caution: Icons.warning_amber_outlined,
  RecommendationKind.info: Icons.info_outline,
  RecommendationKind.blocked: Icons.block,
};

/// The local minicoach (F16): today's advice, suggestions, things to keep in
/// mind, the profile and how it works. The rules are local; nothing here is
/// a diagnosis.
class CoachPage extends StatefulWidget {
  const CoachPage({
    super.key,
    required this.vm,
    required this.onAction,
    required this.onProfile,
    this.only,
    this.extra,
  });
  final CoachAdviceViewModel vm;
  final CoachActionHandler onAction;
  final VoidCallback onProfile;

  /// Show only one family (the plan review opened from Plan).
  final RuleFamily? only;

  /// An optional card under the profile (the external assistant).
  final Widget? extra;

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final only = widget.only;
    return Scaffold(
      appBar: AppBar(
        title: Text(only == null ? 'Minicoach' : 'Revisión del plan'),
        backgroundColor: ForjaColors.paper,
        foregroundColor: ForjaColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: VmObserver(
          viewModel: widget.vm,
          builder: (context) =>
              only == null ? _full(context) : _family(context, only),
        ),
      ),
    );
  }

  Widget _family(BuildContext context, RuleFamily family) {
    final items = widget.vm.ofFamily(family);
    return ResponsivePage(
      maxWidth: Breakpoints.readable,
      header: const PageHeading(
        'REVISIÓN DEL PLAN',
        subtitle: 'Lo que dicen las reglas locales sobre tu plan.',
      ),
      primary: [
        if (items.isEmpty)
          const EmptyState(
            icon: Icons.check_circle_outline,
            title: 'Nada que revisar',
            message: 'Las reglas no ven nada que cambiar en tu plan ahora.',
          ),
        for (final r in items) ...[_card(r), const SizedBox(height: 12)],
        const _HowItWorks(),
      ],
    );
  }

  Widget _full(BuildContext context) {
    final vm = widget.vm;
    final today = vm.forToday;
    final suggestions = vm.suggestions;
    final shown = _all ? suggestions : suggestions.take(3).toList();
    final line = vm.result.todayLine;
    return ResponsivePage(
      header: const PageHeading(
        'MINICOACH',
        subtitle: 'Consejos de tus reglas locales, con su porqué.',
      ),
      primary: [
        _Section(
          title: 'Hoy',
          children: [
            if (line == null && today.isEmpty)
              const SurfaceCard(
                child: Text('Nada especial para hoy: sigue tu plan como está.'),
              ),
            if (line != null && today.isEmpty) SurfaceCard(child: Text(line)),
            for (final r in today) ...[_card(r), const SizedBox(height: 12)],
          ],
        ),
        _Section(
          title: 'Sugerencias',
          children: [
            if (suggestions.isEmpty)
              const SurfaceCard(
                child: Text(
                  'Sin sugerencias por ahora. Cuantos más datos registres '
                  '(series, RIR, técnica), mejor afinan las reglas.',
                ),
              ),
            for (final r in shown) ...[_card(r), const SizedBox(height: 12)],
            if (suggestions.length > 3)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const ValueKey('coach-more'),
                  onPressed: () => setState(() => _all = !_all),
                  child: Text(
                    _all ? 'Ver menos' : 'Ver más (${suggestions.length - 3})',
                  ),
                ),
              ),
          ],
        ),
      ],
      secondary: [
        if (vm.notes.isNotEmpty)
          _Section(
            title: 'Para tener en cuenta',
            children: [
              for (final r in vm.notes) ...[
                _card(r),
                const SizedBox(height: 12),
              ],
            ],
          ),
        _Section(
          title: 'Perfil y revisión',
          children: [
            SurfaceCard(
              child: QuickRow(
                key: const ValueKey('coach-profile'),
                icon: Icons.account_circle_outlined,
                title: vm.needsProfile ? 'Completa tu perfil' : 'Tu perfil',
                subtitle: vm.needsProfile
                    ? 'Con tu objetivo, días y equipo los consejos se ajustan a ti.'
                    : 'Objetivo, días, equipo y revisión mensual',
                onTap: widget.onProfile,
              ),
            ),
            if (widget.extra != null) ...[
              const SizedBox(height: 12),
              widget.extra!,
            ],
          ],
        ),
        _Section(
          title: 'Tipos de consejo',
          children: [
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final f in RuleFamily.values)
                    if (f != RuleFamily.safety)
                      SwitchListTile(
                        key: ValueKey('coach-family-${f.name}'),
                        title: Text(f.label),
                        subtitle: Text(vm.muted(f) ? 'Ocultos' : 'Visibles'),
                        value: !vm.muted(f),
                        onChanged: vm.busy
                            ? null
                            : (show) => vm.setMuted(f, !show),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los avisos de seguridad (lesión, dolor, vuelta tras una pausa) '
              'no se pueden ocultar.',
            ),
          ],
        ),
        const _HowItWorks(),
      ],
    );
  }

  Widget _card(Recommendation r) => RecommendationCard(
    recommendation: r,
    busy: widget.vm.busy,
    onWhy: () => showWhy(context, widget.vm, r),
    onDismiss: () => widget.vm.dismiss(r),
    onAction: () async {
      final action = r.action;
      if (action == null) return;
      if (action is IncreaseLoad) {
        await widget.vm.acceptIncrease(r);
      } else {
        await widget.onAction(context, action);
      }
    },
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          'Cómo funciona',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const SizedBox(height: 8),
      const SurfaceCard(
        child: Text(
          'Son reglas locales y explicables ($expertKbVersion): miran tus '
          'registros en este teléfono, sin Internet. Cada consejo dice en qué '
          'datos se basa y cuánto respaldo tiene (alta, media o heurística). '
          'Nada se aplica solo: tú decides. «Ahora no» lo oculta unos días. '
          'Con una lesión o dolor registrados no se sugieren aumentos.',
        ),
      ),
      const SizedBox(height: 12),
      const SurfaceCard(
        light: true,
        child: Text(
          'No es un diagnóstico. Si notas dolor en el pecho, mareo o desmayo, '
          'o una falta de aire desproporcionada, para y busca atención '
          'médica.',
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

/// One recommendation: what, why, and what you can do.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onWhy,
    required this.onDismiss,
    required this.onAction,
    this.busy = false,
  });
  final Recommendation recommendation;
  final VoidCallback onWhy, onDismiss, onAction;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final r = recommendation;
    final action = r.kind == RecommendationKind.blocked ? null : r.action;
    return Semantics(
      container: true,
      child: SurfaceCard(
        key: ValueKey('coach-card-${r.key}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(_kindIcons[r.kind], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_kindLabels[r.kind]} · ${r.family.label}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(r.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(r.summary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (action != null)
                  FilledButton(
                    key: ValueKey('coach-accept-${r.key}'),
                    style: toneStyle(ActionTone.confirm),
                    onPressed: busy ? null : onAction,
                    // An arrow for the actions that only open a screen, a
                    // check for the ones that apply a change after confirming.
                    child: ToneLabel(
                      action is IncreaseLoad ||
                              action is AddVolume ||
                              action is AdvanceExercise
                          ? Icons.check
                          : Icons.arrow_forward,
                      action.label,
                    ),
                  ),
                OutlinedButton(
                  key: ValueKey('coach-why-${r.key}'),
                  onPressed: onWhy,
                  child: const Text('Por qué'),
                ),
                TextButton(
                  key: ValueKey('coach-dismiss-${r.key}'),
                  style: toneStyle(ActionTone.caution),
                  onPressed: busy ? null : onDismiss,
                  child: const ToneLabel(Icons.snooze, 'Ahora no'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The facts, rule, version, evidence, threshold and trace behind [r].
Future<void> showWhy(
  BuildContext context,
  CoachAdviceViewModel vm,
  Recommendation r,
) => showForjaSheet<void>(
  context,
  title: 'Por qué',
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(r.title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      Text('En qué se basa', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 4),
      for (final f in r.because)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            f.date == null
                ? '• ${f.label}: ${f.value}'
                : '• ${shortDate(parseDateKey(f.date!))} · ${f.label}: ${f.value}',
          ),
        ),
      const SizedBox(height: 12),
      Text('Regla', style: Theme.of(context).textTheme.labelLarge),
      Text('${r.ruleId} · ${vm.result.kbVersion}'),
      if (r.threshold != null) Text('Umbral: ${r.threshold}'),
      const SizedBox(height: 12),
      Text('Respaldo', style: Theme.of(context).textTheme.labelLarge),
      Text(
        '${r.evidence.level.label[0].toUpperCase()}'
        '${r.evidence.level.label.substring(1)}: ${r.evidence.source}',
      ),
      if (r.vetoedBy != null) ...[
        const SizedBox(height: 12),
        Text('Detenida por', style: Theme.of(context).textTheme.labelLarge),
        Text(r.vetoedBy!),
      ],
      const SizedBox(height: 12),
      Text('Traza', style: Theme.of(context).textTheme.labelLarge),
      for (final f in vm.traceOf(r)) Text('• $f'),
      const SizedBox(height: 12),
      const Text(
        'Las reglas son una ayuda para organizarte, no un diagnóstico. Tú '
        'decides qué hacer.',
      ),
    ],
  ),
);
