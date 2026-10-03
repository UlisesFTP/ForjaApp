import 'package:flutter/material.dart';

import '../../core/theme/forja_theme.dart';
import 'view_model.dart';

/// Displays the VM's saved/error message once, including screen reader announcement
/// provided by Material's SnackBar. Views never read storage directly.
class VmObserver extends StatefulWidget {
  const VmObserver({super.key, required this.viewModel, required this.builder});
  final ViewModel viewModel;
  final WidgetBuilder builder;
  @override
  State<VmObserver> createState() => _VmObserverState();
}

class _VmObserverState extends State<VmObserver> {
  late int version;
  @override
  void initState() {
    super.initState();
    version = widget.viewModel.messageVersion;
    widget.viewModel.addListener(changed);
  }

  void changed() {
    if (!mounted) return;
    if (version != widget.viewModel.messageVersion) {
      version = widget.viewModel.messageVersion;
      final message = widget.viewModel.message;
      final label = widget.viewModel.messageActionLabel;
      final action = widget.viewModel.messageAction;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                // An undo window longer than the default: it is the only way
                // back from a move.
                duration: action == null
                    ? const Duration(seconds: 4)
                    : const Duration(seconds: 10),
                action: action == null || label == null
                    ? null
                    : SnackBarAction(label: label, onPressed: action),
              ),
            );
        }
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.light = false,
  });
  final Widget child;
  final EdgeInsets padding;
  final bool light;
  @override
  Widget build(BuildContext context) => Material(
    color: light ? ForjaColors.paper : ForjaColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: light
          ? BorderSide.none
          : const BorderSide(color: ForjaColors.border),
    ),
    child: Padding(
      padding: padding,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: light ? ForjaColors.ink : ForjaColors.text),
        child: child,
      ),
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FittedHeading(title),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// A page title that wraps between words but never inside one: when its
/// longest word is wider than the line (320 px with large text: "EJERCICIOS"
/// broke into "EJERCICI/OS"), the size goes down just enough for it to fit.
class _FittedHeading extends StatelessWidget {
  const _FittedHeading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineLarge!;
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        var widest = 0.0;
        for (final word in title.split(RegExp(r'\s+'))) {
          final painter = TextPainter(
            text: TextSpan(text: word, style: style),
            textScaler: scaler,
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          if (painter.width > widest) widest = painter.width;
          painter.dispose();
        }
        final fits = widest <= constraints.maxWidth || style.fontSize == null;
        return Text(
          title,
          style: fits
              ? style
              : style.copyWith(
                  fontSize:
                      style.fontSize! * constraints.maxWidth / widest * 0.98,
                ),
        );
      },
    );
  }
}

class QuickRow extends StatelessWidget {
  const QuickRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      minTileHeight: 48,
      leading: Icon(icon, color: ForjaColors.paper),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

Future<T?> showForjaSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  // Full width on a phone; on a tablet a comfortable form width.
  constraints: const BoxConstraints(maxWidth: 600),
  backgroundColor: ForjaColors.background,
  barrierLabel: 'Cerrar $title',
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar $title',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
  ),
);

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        Icon(icon, size: 40),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}
