import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/forja_theme.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../core/widgets.dart';
import '../view_models/ai_settings_view_model.dart';
import 'ai_consent_page.dart';
import '../../core/tone_buttons.dart';

/// Más → Asistente IA (opcional) (F17, D38).
Future<void> showAiSettings(BuildContext context, AiSettingsViewModel vm) =>
    showForjaSheet<void>(
      context,
      title: 'Asistente IA',
      child: _AiSettings(vm),
    );

/// Where the last action happened, so its error shows right under it.
enum _Spot { provider, key, test, switcher }

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
  _Spot? _spot;

  /// The person chose to type a model that is not in the list.
  late bool _typingModel = _isOtherModel(widget.vm.settings);

  static bool _isOtherModel(AiSettings s) =>
      s.provider == AiProvider.custom ||
      (s.model.isNotEmpty && s.preset.option(s.model) == null);

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

  void _syncFields() {
    final s = widget.vm.settings;
    _baseUrl.text = s.baseUrl;
    _model.text = s.model;
    _typingModel = _isOtherModel(s);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty && mounted) {
      setState(() => _key.text = text);
    }
  }

  Future<void> _saveKey() async {
    _spot = _Spot.key;
    if (await widget.vm.saveKey(_key.text) && mounted) {
      setState(() {
        _key.clear();
        _show = false;
      });
    }
  }

  Future<bool> _confirm(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: toneStyle(ActionTone.danger),
              onPressed: () => Navigator.pop(context, true),
              child: ToneLabel(Icons.delete_outline, action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteKey() async {
    _spot = _Spot.key;
    final sure = await _confirm(
      '¿Eliminar la clave?',
      'Se borra del almacenamiento seguro de este teléfono. El asistente '
          'no podrá responder hasta que escribas otra.',
      'Eliminar',
    );
    if (sure) await widget.vm.deleteKey();
  }

  Future<void> _forget() async {
    final sure = await _confirm(
      '¿Desactivar y borrar todo?',
      'Se borran la clave, tu consentimiento y los ajustes y contadores '
          'del asistente. Tus entrenamientos y comidas no se tocan.',
      'Borrar',
    );
    if (sure && await widget.vm.forgetAll() && mounted) {
      setState(_syncFields);
    }
  }

  Future<void> _toggle(bool on) async {
    final vm = widget.vm;
    _spot = _Spot.switcher;
    if (!on) {
      await vm.disable();
      return;
    }
    // Turning it on is the consent page's "Acepto y activar", nothing else.
    await showAiConsent(context, vm);
  }

  /// A list of options in a sheet: large targets, one choice, wraps with
  /// any text size.
  Future<T?> _pick<T>({
    required String title,
    required T? selected,
    required List<({T value, String label, String note, Key key})> options,
    String? footer,
  }) => showForjaSheet<T>(
    context,
    title: title,
    child: RadioGroup<T>(
      groupValue: selected,
      onChanged: (v) => Navigator.of(context).pop(v),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final o in options)
            RadioListTile<T>(
              key: o.key,
              contentPadding: EdgeInsets.zero,
              value: o.value,
              title: Text(o.label),
              subtitle: o.note.isEmpty ? null : Text(o.note),
            ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(footer, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    ),
  );

  Future<void> _chooseProvider() async {
    final vm = widget.vm;
    _spot = _Spot.provider;
    final p = await _pick<AiProvider>(
      title: 'Proveedor',
      selected: vm.settings.provider,
      options: [
        for (final p in aiProviderOrder)
          (
            value: p,
            label: aiPresets[p]!.label,
            note: aiPresets[p]!.summary,
            key: ValueKey('ai-provider-${p.name}'),
          ),
      ],
      footer:
          'Todos funcionan con tu propia clave. Cambiar de proveedor pide '
          'volver a aceptar el consentimiento.',
    );
    if (p == null || p == vm.settings.provider || !mounted) return;
    if (await vm.setProvider(p) && mounted) setState(_syncFields);
  }

  static const _other = '\u0000other';

  Future<void> _chooseModel() async {
    final vm = widget.vm, s = vm.settings;
    _spot = _Spot.provider;
    final id = await _pick<String>(
      title: 'Modelo',
      selected: _typingModel ? _other : s.model,
      options: [
        for (final m in s.preset.models)
          (
            value: m.id,
            label: m.label,
            note: '${m.note} · ${m.id}',
            key: ValueKey('ai-model-${m.id}'),
          ),
        (
          value: _other,
          label: 'Otro modelo…',
          note: 'Escribe el identificador que indique tu proveedor.',
          key: const ValueKey('ai-model-other'),
        ),
      ],
      footer:
          'Lista de modelos populares de ${s.preset.label}. Usa «Probar '
          'conexión» para comprobar que tu clave puede usar el elegido.',
    );
    if (id == null || !mounted) return;
    if (id == _other) {
      setState(() => _typingModel = true);
      return;
    }
    setState(() {
      _typingModel = false;
      _model.text = id;
    });
    await vm.setAddress(model: id);
  }

  Widget _header(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 4),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );

  /// A tappable row that looks and reads like a drop-down menu.
  Widget _picker(
    BuildContext context, {
    required Key key,
    required String label,
    required String value,
    String? note,
    required VoidCallback? onTap,
  }) => Semantics(
    button: true,
    label: '$label: $value. Toca para cambiar.',
    excludeSemantics: true,
    onTap: onTap,
    child: Material(
      color: ForjaColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: ForjaColors.border),
      ),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (note != null)
                        Text(
                          note,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  /// The error of the last action, right under that action.
  Widget _errorFor(_Spot spot) {
    final e = widget.vm.error;
    if (e == null || _spot != spot) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                e,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressEditor(AiSettingsViewModel vm, {required bool withModel}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('ai-base-url'),
            controller: _baseUrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Dirección (https)',
              hintText: 'https://api.ejemplo.com/v1',
            ),
            onSubmitted: (v) => vm.setAddress(baseUrl: v),
          ),
          if (withModel) ...[const SizedBox(height: 8), _modelField(vm)],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const ValueKey('ai-save-address'),
              onPressed: vm.busy
                  ? null
                  : () => vm.setAddress(
                      baseUrl: _baseUrl.text,
                      model: withModel ? _model.text : null,
                    ),
              child: Text(
                withModel ? 'Guardar dirección y modelo' : 'Guardar dirección',
              ),
            ),
          ),
        ],
      );

  Widget _modelField(AiSettingsViewModel vm) => TextField(
    key: const ValueKey('ai-model'),
    controller: _model,
    autocorrect: false,
    enableSuggestions: false,
    decoration: const InputDecoration(
      labelText: 'Modelo',
      hintText: 'Identificador del modelo',
    ),
    onSubmitted: (v) => vm.setAddress(model: v),
  );

  String _summary(AiSettingsViewModel vm) {
    final s = vm.settings;
    if (s.problem != null) return 'Falta corregir: ${s.problem}.';
    if (!vm.hasKey) return 'Siguiente paso: pega tu clave API (paso 2).';
    if (!vm.enabled) return 'Todo listo para activarlo. Actívalo abajo.';
    return 'Activo con ${s.preset.label} · ${_modelLabel(s)}.';
  }

  static String _modelLabel(AiSettings s) =>
      s.preset.option(s.model)?.label ?? s.model;

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final vm = widget.vm, s = vm.settings, preset = s.preset;
      final today = vm.today;
      final custom = s.provider == AiProvider.custom;
      final canTest =
          !(vm.busy || vm.testing || !vm.hasKey || s.problem != null);
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
          // The state and the switch together, first thing on the sheet.
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  key: const ValueKey('ai-enabled'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activar el asistente'),
                  subtitle: Text(
                    vm.enabled
                        ? 'Activo · ${preset.label} · ${s.model}'
                        : 'Desactivado',
                  ),
                  value: vm.enabled,
                  onChanged: vm.busy ? null : _toggle,
                ),
                Semantics(liveRegion: true, child: Text(_summary(vm))),
                _errorFor(_Spot.switcher),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _header(context, 'Paso 1 · Proveedor y modelo'),
          _picker(
            context,
            key: const ValueKey('ai-provider-picker'),
            label: 'Proveedor',
            value: preset.label,
            note: preset.summary,
            onTap: vm.busy ? null : _chooseProvider,
          ),
          const SizedBox(height: 8),
          if (custom)
            _addressEditor(vm, withModel: true)
          else ...[
            _picker(
              context,
              key: const ValueKey('ai-model-picker'),
              label: 'Modelo',
              value: _typingModel ? 'Otro modelo' : _modelLabel(s),
              note: _typingModel
                  ? null
                  : preset.option(s.model)?.note ?? s.model,
              onTap: vm.busy ? null : _chooseModel,
            ),
            if (_typingModel) ...[
              const SizedBox(height: 8),
              _modelField(vm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const ValueKey('ai-save-model'),
                  onPressed: vm.busy
                      ? null
                      : () => vm.setAddress(model: _model.text),
                  child: const Text('Usar este modelo'),
                ),
              ),
            ],
          ],
          if (preset.risk != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(preset.risk!),
            ),
          if (s.problem != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'No se puede usar: ${s.problem}.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          _errorFor(_Spot.provider),
          const SizedBox(height: 16),
          _header(context, 'Paso 2 · Tu clave'),
          Text(preset.keyHint),
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
                style: toneStyle(ActionTone.confirm),
                onPressed: vm.busy || _key.text.trim().isEmpty
                    ? null
                    : _saveKey,
                child: const ToneLabel(Icons.lock_outline, 'Guardar clave'),
              ),
              if (vm.hasKey)
                TextButton(
                  key: const ValueKey('ai-delete-key'),
                  style: toneStyle(ActionTone.danger),
                  onPressed: vm.busy ? null : _deleteKey,
                  child: const ToneLabel(
                    Icons.key_off_outlined,
                    'Eliminar clave',
                  ),
                ),
            ],
          ),
          _errorFor(_Spot.key),
          const SizedBox(height: 16),
          _header(context, 'Paso 3 · Probar la conexión'),
          const Text(
            'Envía tres mensajes técnicos («ok», una herramienta de prueba y un '
            'JSON), sin datos tuyos.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('ai-test'),
            onPressed: canTest
                ? () {
                    _spot = _Spot.test;
                    vm.testConnection();
                  }
                : null,
            icon: const Icon(Icons.wifi_tethering),
            label: Text(vm.testing ? 'Probando…' : 'Probar conexión'),
          ),
          if (!canTest && !vm.testing && !vm.busy)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                s.problem != null
                    ? 'Corrige el paso 1 para poder probar.'
                    : 'Guarda tu clave (paso 2) para poder probar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (vm.report != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  'Conexión correcta. Herramientas: '
                  '${vm.report!.capabilities.tools ? 'sí' : 'no (el chat usará un resumen)'}'
                  ' · JSON: ${vm.report!.capabilities.jsonMode ? 'sí' : 'no'}',
                ),
              ),
            ),
          _errorFor(_Spot.test),
          const SizedBox(height: 8),
          const Divider(),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const ValueKey('ai-more'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Más opciones'),
              subtitle: const Text(
                'Funciones, datos que puede consultar, tope diario y dirección.',
              ),
              children: [
                _header(context, 'Funciones'),
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
                  _header(context, 'Qué puede consultar'),
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
                _header(context, 'Uso de hoy'),
                Text(
                  '${today.requests} de ${s.dailyCap} peticiones · '
                  '${today.usage.total} tokens (entrada ${today.usage.prompt}, '
                  'salida ${today.usage.completion}).',
                ),
                const SizedBox(height: 8),
                const Text('Tope diario'),
                // Chips wrap at any text size (a dropdown overflowed at
                // 320 px with text at 200 %).
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
                if (!custom) ...[
                  const Divider(),
                  _header(context, 'Dirección del proveedor'),
                  const Text(
                    'Solo cámbiala si usas un proxy o una dirección propia. '
                    'Otra dirección pide volver a aceptar el consentimiento.',
                  ),
                  const SizedBox(height: 8),
                  _addressEditor(vm, withModel: false),
                ],
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Nunca se envían tus copias de seguridad ni la clave a la IA. '
            'Lo que consulta va a tu proveedor solo cuando le pides algo. '
            'No es un diagnóstico.',
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('ai-forget'),
            style: toneStyle(ActionTone.danger),
            onPressed: vm.busy ? null : _forget,
            child: const ToneLabel(
              Icons.delete_forever_outlined,
              'Desactivar y borrar todo lo del asistente',
            ),
          ),
        ],
      );
    },
  );
}
