import 'dart:async';

import '../../../data/services/ai/ai_gateway.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../core/view_model.dart';

/// The assistant's sheet (F17): provider, key, consent, switches and the
/// connection test. Every change is the person's explicit action; nothing
/// here sends personal data.
class AiSettingsViewModel extends ViewModel {
  AiSettingsViewModel(this.gateway) {
    watch(gateway);
    unawaited(gateway.load());
  }
  final AiGateway gateway;

  AiSettings get settings => gateway.settings;
  bool get enabled => settings.enabled && gateway.consentValid;
  bool get hasKey => gateway.hasKey;
  String? get keyTail => gateway.keyTail;
  Set<DataCategory> get categories => gateway.categories;
  AiUsageDay get today => gateway.today;
  bool get testing => gateway.testing;
  AiConnectionReport? report;

  Future<bool> saveKey(String key) => run(
    () => gateway.saveKey(key),
    success: 'Clave guardada en el almacenamiento seguro del teléfono.',
  );

  Future<bool> deleteKey() =>
      run(gateway.deleteKey, success: 'Clave eliminada del teléfono.');

  /// Choosing a preset fills its address and model. Another provider or
  /// address asks for consent again.
  Future<bool> setProvider(AiProvider provider) {
    final preset = aiPresets[provider]!;
    return run(
      () => gateway.updateSettings(
        settings.copyWith(
          provider: provider,
          baseUrl: provider == AiProvider.custom ? '' : preset.baseUrl,
          model: provider == AiProvider.custom ? '' : preset.model,
          capabilities: () => null,
        ),
      ),
    );
  }

  Future<bool> setAddress({String? baseUrl, String? model}) => run(
    () => gateway.updateSettings(
      settings.copyWith(
        baseUrl: baseUrl?.trim(),
        model: model?.trim(),
        capabilities: () => null,
      ),
    ),
    success: 'Guardado',
  );

  Future<bool> setFeature(AiFeature feature, bool on) => run(
    () => gateway.updateSettings(
      settings.copyWith(
        features: on
            ? {...settings.features, feature}
            : ({...settings.features}..remove(feature)),
      ),
    ),
  );

  Future<bool> setDailyCap(int cap) =>
      run(() => gateway.updateSettings(settings.copyWith(dailyCap: cap)));

  Future<bool> setCategory(DataCategory category, bool allowed) =>
      run(() => gateway.setCategory(category, allowed));

  /// "Acepto y activar" on the consent page: the only way to turn it on.
  Future<bool> accept(Set<DataCategory> categories) => run(
    () => gateway.accept(categories),
    success: 'Asistente activado. Puedes desactivarlo cuando quieras.',
  );

  Future<bool> disable() => run(
    gateway.disable,
    success: 'Asistente desactivado. El minicoach local sigue igual.',
  );

  Future<bool> forgetAll() => run(
    gateway.forgetAll,
    success: 'Se borraron la clave y los ajustes del asistente.',
  );

  Future<bool> testConnection() => run(() async {
    report = null;
    report = await gateway.testConnection();
    final r = report!;
    announce(
      'Conexión correcta: ${r.model.isEmpty ? settings.model : r.model} '
      'en ${(r.latency.inMilliseconds / 1000).toStringAsFixed(1)} s.',
    );
  });
}
