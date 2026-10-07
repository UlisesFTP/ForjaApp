import 'package:flutter/material.dart';

import '../../../core/theme/forja_theme.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/ai_settings_view_model.dart';
import '../../core/tone_buttons.dart';

/// The explicit consent for the external assistant (F17, D38). Only "Acepto
/// y activar" gives consent; going back changes nothing.
Future<void> showAiConsent(BuildContext context, AiSettingsViewModel vm) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => AiConsentPage(vm: vm)));

class AiConsentPage extends StatefulWidget {
  const AiConsentPage({super.key, required this.vm});
  final AiSettingsViewModel vm;
  @override
  State<AiConsentPage> createState() => _AiConsentPageState();
}

class _AiConsentPageState extends State<AiConsentPage> {
  // All on by the person's choice (D38); each one can be turned off here or
  // later.
  final _categories = {...DataCategory.values};

  Future<void> _accept() async {
    if (await widget.vm.accept(_categories) && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm, s = vm.settings, preset = s.preset;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antes de activar'),
        backgroundColor: ForjaColors.paper,
        foregroundColor: ForjaColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: VmObserver(
          viewModel: vm,
          builder: (context) => ResponsivePage(
            maxWidth: Breakpoints.readable,
            header: const PageHeading(
              'ASISTENTE EXTERNO (IA)',
              subtitle: 'Opcional. Lee esto antes de activarlo.',
            ),
            primary: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'A quién se envía',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('${preset.label} · ${s.model} · ${s.baseUrl}'),
                    const SizedBox(height: 6),
                    Text(preset.hosting),
                    Text(preset.retention),
                    if (preset.risk != null) ...[
                      const SizedBox(height: 6),
                      Text(preset.risk!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SurfaceCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Qué podrá consultar cuando le preguntes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    for (final c in DataCategory.values)
                      SwitchListTile(
                        key: ValueKey('consent-${c.name}'),
                        title: Text(c.label),
                        subtitle: Text(c.description),
                        value: _categories.contains(c),
                        onChanged: (on) => setState(
                          () => on ? _categories.add(c) : _categories.remove(c),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SurfaceCard(
                child: Text(
                  'Lo que nunca se envía: tus copias de seguridad y tu clave. '
                  'Nada sale del teléfono hasta que le pides algo al '
                  'asistente, y cada respuesta muestra qué consultó. Solo '
                  'propone: nada se guarda sin que tú lo confirmes, y con una '
                  'lesión registrada no se aceptan aumentos. Puedes retirar '
                  'este permiso cuando quieras en Más → Asistente IA.',
                ),
              ),
              const SizedBox(height: 12),
              const SurfaceCard(
                light: true,
                child: Text(
                  'Es una IA externa, no un profesional: puede equivocarse y '
                  'no es un diagnóstico. Ante dolor en el pecho, mareo o '
                  'desmayo, para y busca atención médica.',
                ),
              ),
              const SizedBox(height: 16),
              if (s.problem != null)
                Text('Revisa los ajustes: ${s.problem}.')
              else if (!vm.hasKey)
                const Text(
                  'Falta tu clave: guárdala en la hoja del asistente antes de '
                  'activarlo.',
                ),
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey('ai-consent-accept'),
                onPressed: vm.busy || s.problem != null || !vm.hasKey
                    ? null
                    : _accept,
                style: toneStyle(ActionTone.confirm),
                child: const ToneLabel(
                  Icons.verified_user_outlined,
                  'Acepto y activar',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const ValueKey('ai-consent-cancel'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ahora no'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
