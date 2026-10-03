import 'package:flutter/material.dart';

import '../../core/theme/forja_theme.dart';

/// The fixed label of anything the external assistant says (F17, D38):
/// external, an AI, and not a diagnosis. Monochrome, like the rest.
class AiBadge extends StatelessWidget {
  const AiBadge({super.key, this.detail});

  /// The model and provider, when known.
  final String? detail;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: ForjaColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Asistente externo (IA)'
                '${detail == null ? '' : ' · $detail'} · No es un diagnóstico',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
