import 'package:flutter/material.dart';

import '../../core/theme/forja_theme.dart';

/// The meaning of a key action button (D44). The colour never stands alone:
/// every coloured button also has an icon and its text label.
enum ActionTone {
  /// Confirm, save, accept, complete.
  confirm,

  /// Caution: skip, postpone, "not now", reject.
  caution,

  /// Destructive: delete, discard, replace.
  danger,
}

/// The solid colour of [tone] at rest. White text and icons keep at least
/// 4.5:1 on it, in the paper cards and on the dark surfaces alike.
Color toneAccent(ActionTone tone) => switch (tone) {
  ActionTone.confirm => ForjaColors.success,
  ActionTone.caution => ForjaColors.caution,
  ActionTone.danger => ForjaColors.danger,
};

/// The fill of [tone] for a set of button [states]. Hover and focus darken
/// it a little and pressing darkens it more (never lighter, so the white
/// label keeps its contrast); a disabled button is a quiet grey.
Color toneFill(ActionTone tone, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) return ForjaColors.border;
  final accent = toneAccent(tone);
  if (states.contains(WidgetState.pressed)) {
    return Color.lerp(accent, Colors.black, .26)!;
  }
  if (states.contains(WidgetState.hovered) ||
      states.contains(WidgetState.focused)) {
    return Color.lerp(accent, Colors.black, .12)!;
  }
  return accent;
}

/// The text and icon colour on a [toneFill].
const toneText = ForjaColors.onTone;

/// Compact, solid, white-on-colour style of an action button. Hover and
/// focus darken the fill and add a light outline (focus a thicker one);
/// pressing darkens it more. Works for `FilledButton`, `OutlinedButton` and
/// `TextButton`, which keep their own widget type. The visible button is
/// 40 px tall; its tap target stays 48 px.
ButtonStyle toneStyle(ActionTone tone) {
  bool disabled(Set<WidgetState> s) => s.contains(WidgetState.disabled);
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(48, 40)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    tapTargetSize: MaterialTapTargetSize.padded,
    elevation: const WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    animationDuration: const Duration(milliseconds: 120),
    backgroundColor: WidgetStateProperty.resolveWith((s) => toneFill(tone, s)),
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => disabled(s) ? ForjaColors.muted : toneText,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (s) => disabled(s) ? ForjaColors.muted : toneText,
    ),
    iconSize: const WidgetStatePropertyAll(18),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
    // The fill already shows hover and focus; the ripple shows the press.
    overlayColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.pressed)
          ? Colors.white.withValues(alpha: .16)
          : null,
    ),
    side: WidgetStateProperty.resolveWith((s) {
      if (disabled(s)) return BorderSide.none;
      if (s.contains(WidgetState.focused)) {
        return const BorderSide(color: toneText, width: 2.5);
      }
      if (s.contains(WidgetState.hovered)) {
        return BorderSide(color: toneText.withValues(alpha: .7), width: 1.5);
      }
      return BorderSide.none;
    }),
    mouseCursor: WidgetStateProperty.resolveWith(
      (s) => disabled(s) ? SystemMouseCursors.basic : SystemMouseCursors.click,
    ),
  );
}

/// The style of a coloured `IconButton` (the trash can): a compact solid
/// square with a white icon, with the same hover, focus and press feedback.
ButtonStyle toneIconStyle(ActionTone tone) {
  bool disabled(Set<WidgetState> s) => s.contains(WidgetState.disabled);
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
    fixedSize: const WidgetStatePropertyAll(Size(40, 40)),
    padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
    tapTargetSize: MaterialTapTargetSize.padded,
    iconSize: const WidgetStatePropertyAll(20),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    backgroundColor: WidgetStateProperty.resolveWith((s) => toneFill(tone, s)),
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => disabled(s) ? ForjaColors.muted : toneText,
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.pressed)
          ? Colors.white.withValues(alpha: .16)
          : null,
    ),
    side: WidgetStateProperty.resolveWith((s) {
      if (disabled(s)) return BorderSide.none;
      if (s.contains(WidgetState.focused)) {
        return const BorderSide(color: toneText, width: 2.5);
      }
      if (s.contains(WidgetState.hovered)) {
        return BorderSide(color: toneText.withValues(alpha: .7), width: 1.5);
      }
      return BorderSide.none;
    }),
    mouseCursor: WidgetStateProperty.resolveWith(
      (s) => disabled(s) ? SystemMouseCursors.basic : SystemMouseCursors.click,
    ),
  );
}

/// The content of a coloured button: its icon and its text. Inside a button
/// styled with [toneStyle] the icon takes the button's icon colour (also when
/// disabled); in a menu item pass [iconColor]. The text wraps with large
/// text sizes.
class ToneLabel extends StatelessWidget {
  const ToneLabel(this.icon, this.label, {super.key, this.iconColor});
  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: iconColor),
      const SizedBox(width: 6),
      Flexible(child: Text(label, textAlign: TextAlign.center)),
    ],
  );
}
