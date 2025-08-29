import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/theme_provider.dart';
import '../../theme/spacing.dart';
import 'components/data_source_section.dart';
import 'components/custom_api_section.dart';
import 'components/theme_section.dart';
import 'components/feature_switch_section.dart';
import 'components/general_functions_section.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DataSourceSection(),
            const SizedBox(height: AppSpacing.lg),
            const CustomApiSection(),
            const SizedBox(height: AppSpacing.lg),
            const ThemeSection(),
            const SizedBox(height: AppSpacing.lg),
            const FeatureSwitchSection(),
            const SizedBox(height: AppSpacing.lg),
            const GeneralFunctionsSection(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}