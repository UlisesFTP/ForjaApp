import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/forja_theme.dart';
import '../ui/shell/widgets/shell_view.dart';
import '../ui/startup/view_models/startup_view_model.dart';
import '../ui/startup/widgets/startup_view.dart';
import 'app_dependencies.dart';

MaterialApp _forjaApp(Widget home) => MaterialApp(
  title: 'FORJA',
  debugShowCheckedModeBanner: false,
  theme: forjaTheme(),
  locale: const Locale('es'),
  supportedLocales: const [Locale('es')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: home,
);

class ForjaApp extends StatelessWidget {
  const ForjaApp({
    super.key,
    required this.dependencies,
    this.offerOnboarding = true,
  });
  final AppDependencies dependencies;
  final bool offerOnboarding;
  @override
  Widget build(BuildContext context) => _forjaApp(
    ShellView(dependencies: dependencies, offerOnboarding: offerOnboarding),
  );
}

class ForjaBootstrap extends StatefulWidget {
  const ForjaBootstrap({super.key, this.create = AppDependencies.create});
  final AppDependenciesFactory create;
  @override
  State<ForjaBootstrap> createState() => _ForjaBootstrapState();
}

class _ForjaBootstrapState extends State<ForjaBootstrap> {
  late final StartupViewModel vm;
  @override
  void initState() {
    super.initState();
    vm = StartupViewModel(
      widget.create,
      copyToClipboard: (text) => Clipboard.setData(ClipboardData(text: text)),
    )..open();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (context, _) => vm.dependencies == null
        ? _forjaApp(StartupView(vm: vm))
        : ForjaApp(dependencies: vm.dependencies!),
  );
}
