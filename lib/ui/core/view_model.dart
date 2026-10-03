import 'package:flutter/foundation.dart';

import '../../domain/services/ai/ai_types.dart';

abstract class ViewModel extends ChangeNotifier {
  bool busy = false;
  String? error;
  String? message;
  int messageVersion = 0;
  // An optional action offered with the message (for example "Deshacer").
  String? messageActionLabel;
  VoidCallback? messageAction;
  bool _disposed = false;
  final Set<Listenable> _sources = {};
  void watch(Listenable source) {
    if (_sources.add(source)) source.addListener(_sourceChanged);
  }

  void _sourceChanged() {
    if (!_disposed) notifyListeners();
  }

  void announce(String text, {String? actionLabel, VoidCallback? onAction}) {
    message = text;
    messageActionLabel = onAction == null ? null : actionLabel;
    messageAction = onAction;
    messageVersion++;
    if (!_disposed) notifyListeners();
  }

  Future<bool> run(Future<void> Function() action, {String? success}) async {
    if (busy) return false;
    busy = true;
    error = null;
    if (!_disposed) notifyListeners();
    try {
      await action();
      if (success != null) announce(success);
      return true;
    } catch (e) {
      // The assistant's failures say what happened with the provider; they
      // are not a failed save.
      error = e is AiFailure
          ? e.message
          : e is ArgumentError
          ? e.message?.toString()
          : e is StateError
          ? e.message
          : 'No se pudo guardar. Vuelve a intentarlo.';
      announce(error!);
      return false;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final source in _sources) {
      source.removeListener(_sourceChanged);
    }
    super.dispose();
  }
}
