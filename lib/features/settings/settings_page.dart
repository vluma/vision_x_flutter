import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import 'widgets/data_source_section.dart';
import 'widgets/custom_api_section.dart';
import 'widgets/theme_section.dart';
import 'widgets/feature_switch_section.dart';
import 'widgets/general_functions_section.dart';
import 'settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    _controller.loadSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
        ),
        body: const _SettingsContent(),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: AppSpacing.pageMargin.copyWith(
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataSourceSection(),
            SizedBox(height: AppSpacing.lg),
            CustomApiSection(),
            SizedBox(height: AppSpacing.lg),
            ThemeSection(),
            SizedBox(height: AppSpacing.lg),
            FeatureSwitchSection(),
            SizedBox(height: AppSpacing.lg),
            GeneralFunctionsSection(),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}