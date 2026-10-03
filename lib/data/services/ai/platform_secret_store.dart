import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/services/ai/ai_settings.dart';

/// The assistant's API key in the platform's secure storage (Android
/// Keystore-backed encryption, iOS Keychain). It is never written anywhere
/// else: not the database, preferences, backups or logs (D38).
class PlatformSecretStore implements SecretStore {
  PlatformSecretStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // A key that cannot be decrypted any more (for example after a
            // restore) is dropped; the person types it again.
            aOptions: AndroidOptions(),
            // This device only, and only while unlocked; never synced.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );
  final FlutterSecureStorage _storage;
  static const _key = 'forja.ai.apiKey';

  @override
  Future<String?> readKey() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      // Unreadable is treated as absent: the person types it again.
      return null;
    }
  }

  @override
  Future<void> writeKey(String key) => _storage.write(key: _key, value: key);

  @override
  Future<void> deleteKey() => _storage.delete(key: _key);
}
