import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/services/ai/ai_settings.dart';
import '../../core/widgets.dart';
import '../view_models/ai_settings_view_model.dart';
import 'ai_consent_page.dart';

/// Más → Asistente IA (opcional) (F17, D38).
Future<void> showAiSettings(BuildContext context, AiSettingsViewModel vm) =>
    showForjaSheet<void>(
      context,
      title: 'Asistente IA',
      child: _AiSettings(vm),
    );

class _AiSettings extends StatefulWidget {
  const _AiSettings(this.vm);
  final AiSettingsViewModel vm;
  @override
  State<_AiSettings> createState() => _AiSettingsState();
}

class _AiSettingsState extends State<_AiSettings> {
  final _key = TextEditingController();
  late final _baseUrl = TextEditingController(text: widget.vm.settings.baseUrl);
  late final _model = TextEditingController(text: widget.vm.settings.model);
  bool _show = false;

  @override
  void dispose() {
    // The typed key is not kept in memory longer than needed.
    _key
      ..clear()
      ..dispose();
    _baseUrl.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty && mounted) {
      setState(() => _key.text = text);
    }
  }

  Future<void> _saveKey() async {
    if (await widget.vm.saveKey(_key.text) && mounted) {
      setState(() {
        _key.clear();
        _show = false;
      });
    }
  }

  Future<void> _deleteKey() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar la clave?'),
        content: const Text(
          'Se borra del almacenamiento seguro de este teléfono. El asistente '
          'no podrá responder hasta que escribas otra.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (sure == true) await widget.vm.deleteKey();
  }

  Future<void> _forget() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Desactivar y borrar todo?'),
        content: const Text(
          'Se borran la clave, tu consentimiento y los ajustes y contadores '
          'del asistente. Tus entrenamientos y comidas no se tocan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (sure == true && await widget.vm.forgetAll() && mounted) {
      setState(() {
        _baseUrl.text = widget.vm.settings.baseUrl;
        _model.text = widget.vm.settings.model;
      });
    }
  }

  Future<void> _toggle(bool on) async {
    final vm = widget.vm;
    if (!on) {
      await vm.disable();
      return;
    }
    // Turning it on is the consent page's "Acepto y activar", nothing else.
    await showAiConsent(context, vm);
  }

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final vm = widget.vm, s = vm.settings;
      final today = vm.today;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Opcional y desactivado por defecto. Funciona con tu propia clave: '
            'tus datos solo salen del teléfono cuando le pides algo al '
            'asistente, y cada respuesta muestra qué consultó. El minicoach '
            'local sigue funcionando sin él.',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            key: const ValueKey('ai-enabled'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Activar el asistente'),
            subtitle: Text(
              vm.enabled
                  ? 'Activo · ${s.preset.label} · ${s.model}'
                  : 'Desactivado',
            ),
            value: vm.enabled,
            onChanged: vm.busy ? null : _toggle,
          ),
          const Divider(),
          Text('Proveedor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          RadioGroup<AiProvider>(
            groupValue: s.provider,
            onChanged: (p) async {
              if (p == null || vm.busy) return;
              if (await vm.setProvider(p) && mounted) {
                setState(() {
                  _baseUrl.text = vm.settings.baseUrl;
                  _model.text = vm.settings.model;
                });
              }
            },
            child: Column(
              children: [
                for (final p in AiProvider.values)
                  RadioListTile<AiProvider>(
                    key: ValueKey('ai-provider-${p.name}'),
                    contentPadding: EdgeInsets.zero,
                    value: p,
                    title: Text(aiPresets[p]!.label),
                  ),
              ],
            ),
          ),
          if (s.preset.risk != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(s.preset.risk!),
            ),
          TextField(
            key: const ValueKey('ai-base-url'),
            controller: _baseUrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Dirección (https)'),
            onSubmitted: (v) => vm.setAddress(baseUrl: v),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('ai-model'),
            controller: _model,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Modelo'),
            onSubmitted: (v) => vm.setAddress(model: v),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('ai-save-address'),
              onPressed: vm.busy
                  ? null
                  : () => vm.setAddress(
                      baseUrl: _baseUrl.text,
                      model: _model.text,
                    ),
              child: const Text('Guardar dirección y modelo'),
            ),
          ),
          if (s.problem != null)
            Semantics(
              liveRegion: true,
              child: Text('No se puede usar: ${s.problem}.'),
            ),
          const Divider(),
          Text('Tu clave', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            vm.hasKey
                ? 'Guardada en el almacenamiento seguro del teléfono'
                      '${(vm.keyTail ?? '').isEmpty ? '' : ' · termina en …${vm.keyTail}'}.'
                : 'Sin clave. Solo se guarda en este teléfono, nunca en copias '
                      'de seguridad.',
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('ai-key'),
            controller: _key,
            obscureText: !_show,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: vm.hasKey ? 'Nueva clave' : 'Clave API',
              suffixIcon: IconButton(
                tooltip: _show ? 'Ocultar la clave' : 'Mostrar la clave',
                onPressed: () => setState(() => _show = !_show),
                icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton(
                key: const ValueKey('ai-paste-key'),
                onPressed: _paste,
                child: const Text('Pegar'),
              ),
              FilledButton(
                key: const ValueKey('ai-save-key'),
                onPressed: vm.busy || _key.text.trim().isEmpty
                    ? null
                    : _saveKey,
                child: const Text('Guardar clave'),
              ),
              if (vm.hasKey)
                TextButton(
                  key: const ValueKey('ai-delete-key'),
                  onPressed: vm.busy ? null : _deleteKey,
                  child: const Text('Eliminar clave'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('ai-test'),
            onPressed: vm.busy || vm.testing || !vm.hasKey || s.problem != null
                ? null
                : vm.testConnection,
            icon: const Icon(Icons.wifi_tethering),
            label: Text(vm.testing ? 'Probando…' : 'Probar conexión'),
          ),
          const Text(
            'La prueba envía tres mensajes técnicos («ok», una herramienta de '
            'prueba y un JSON), sin datos tuyos.',
          ),
          if (vm.report != null)
            Semantics(
              liveRegion: true,
              child: Text(
                'Herramientas: ${vm.report!.capabilities.tools ? 'sí' : 'no (el chat usará un resumen)'} · '
                'JSON: ${vm.report!.capabilities.jsonMode ? 'sí' : 'no'}',
              ),
            ),
          const Divider(),
          Text('Funciones', style: Theme.of(context).textTheme.titleMedium),
          for (final f in AiFeature.values)
            SwitchListTile(
              key: ValueKey('ai-feature-${f.name}'),
              contentPadding: EdgeInsets.zero,
              title: Text(f.label),
              value: s.features.contains(f),
              onChanged: vm.busy ? null : (on) => vm.setFeature(f, on),
            ),
          if (vm.enabled) ...[
            const Divider(),
            Text(
              'Qué puede consultar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final c in DataCategory.values)
              SwitchListTile(
                key: ValueKey('ai-category-${c.name}'),
                contentPadding: EdgeInsets.zero,
                title: Text(c.label),
                subtitle: Text(c.description),
                value: vm.categories.contains(c),
                onChanged: vm.busy ? null : (on) => vm.setCategory(c, on),
              ),
          ],
          const Divider(),
          Text('Uso de hoy', style: Theme.of(context).textTheme.titleMedium),
          Text(
            '${today.requests} de ${s.dailyCap} peticiones · '
            '${today.usage.total} tokens (entrada ${today.usage.prompt}, '
            'salida ${today.usage.completion}).',
          ),
          const SizedBox(height: 8),
          const Text('Tope diario'),
          // Chips wrap at any text size (a dropdown overflowed at 320 px
          // with text at 200 %).
          Wrap(
            spacing: 8,
            children: [
              for (final n in const [20, 60, 120, 200])
                ChoiceChip(
                  key: ValueKey('ai-cap-$n'),
                  label: Text('$n peticiones'),
                  selected: s.dailyCap == n,
                  onSelected: vm.busy ? null : (_) => vm.setDailyCap(n),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nunca se envían tus copias de seguridad ni la clave a la IA. '
            'Lo que consulta va a tu proveedor solo cuando le pides algo. '
            'No es un diagnóstico.',
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('ai-forget'),
            onPressed: vm.busy ? null : _forget,
            child: const Text('Desactivar y borrar todo lo del asistente'),
          ),
          if (vm.error != null)
            Semantics(liveRegion: true, child: Text(vm.error!)),
        ],
      );
    },
  );
}
