import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vision_x_flutter/core/themes/spacing.dart';
import '../../widgets/settings_card.dart';
import '../../providers/settings_provider.dart';

/// 自定义API设置区块
/// 
/// 用于添加和管理自定义API数据源
class CustomApiSection extends ConsumerStatefulWidget {
  /// 构造函数
  const CustomApiSection({super.key});

  @override
  ConsumerState<CustomApiSection> createState() => _CustomApiSectionState();
}

class _CustomApiSectionState extends ConsumerState<CustomApiSection> {
  final TextEditingController _apiNameController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiDetailController = TextEditingController();

  @override
  void dispose() {
    _apiNameController.dispose();
    _apiUrlController.dispose();
    _apiDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settingsState = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsCard(
      title: '自定义API',
      content: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 自定义API表单
            if (settingsState.customApiForm.showForm) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    TextField(
                      controller: _apiNameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'API名称',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _apiUrlController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'API地址',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _apiDetailController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: '详情地址（可选）',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: settingsState.customApiForm.isHiddenSource,
                          onChanged: (bool? value) {
                            settingsNotifier.updateIsHiddenSource(value ?? false);
                          },
                        ),
                        const Text('隐藏资源站'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => settingsNotifier.cancelAddCustomApi(),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: () {
                            settingsNotifier.addCustomApi(
                              _apiNameController.text,
                              _apiUrlController.text,
                              _apiDetailController.text,
                              context,
                            );
                            _apiNameController.clear();
                            _apiUrlController.clear();
                            _apiDetailController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 添加自定义API按钮
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => settingsNotifier.showAddCustomApiForm(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加自定义API'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // 自定义API列表
            if (settingsState.settings.customApis.isNotEmpty) ...[
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252525) : Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: settingsState.settings.customApis.length,
                  itemBuilder: (context, index) {
                    final api = settingsState.settings.customApis[index];
                    final isHidden = api['isHidden'] == 'true';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 0,
                        ),
                        title: Text(
                          api['name'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          api['api'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHidden) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '隐藏',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            IconButton(
                              onPressed: () => settingsNotifier.removeCustomApi(index, context),
                              icon: Icon(
                                Icons.delete,
                                color: isDark ? Colors.redAccent : Colors.red,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}