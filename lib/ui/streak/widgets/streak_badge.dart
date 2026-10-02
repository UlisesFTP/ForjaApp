import 'package:flutter/material.dart';

import '../../../core/theme/forja_theme.dart';
import '../view_models/streak_view_model.dart';
import 'streak_flame.dart';

/// The flame and the streak count in the top bar; opens the calendars.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.vm, required this.onOpen});
  final StreakViewModel vm;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (context, _) => Semantics(
      button: true,
      label: '${vm.summary} Abrir calendario de racha.',
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('streak-badge'),
        customBorder: const StadiumBorder(),
        onTap: onOpen,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreakFlame(
                  size: 20,
                  lit: vm.lit,
                  onPaper: true,
                  play: vm.celebrate,
                ),
                const SizedBox(width: 4),
                Text(
                  '${vm.current}',
                  key: const ValueKey('streak-count'),
                  style: const TextStyle(
                    color: ForjaColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
