import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/spacing.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_card.dart';

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
      action: IconButton(
        onPressed: settingsNotifier.showAddCustomApiForm,
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 自定义API列表
          if (settingsState.settings.customApis.isNotEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: settingsState.settings.customApis.length,
                itemBuilder: (context, index) {
                  final api = settingsState.settings.customApis[index];
                  final isHidden = api['isHidden'] == 'true';
                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          api['name']!,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        if (isHidden) ...[ 
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '隐藏',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      api['api']!,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: isDark ? Colors.white38 : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => settingsNotifier.removeCustomApi(index, context),
                    ),
                  );
                },
              ),
            ),
          // 添加自定义API表单
          if (settingsState.customApiForm.showForm) ...[ 
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _apiNameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'API名称',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiUrlController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'https://abc.com',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiDetailController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'detail地址（可选）',
                      labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 隐藏资源站复选框
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: settingsState.customApiForm.isHiddenSource,
                        onChanged: (bool? value) {
                          settingsNotifier.updateIsHiddenSource(value ?? false);
                        },
                      ),
                      Text(
                        '隐藏资源站',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          '添加',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          settingsNotifier.cancelAddCustomApi();
                          _apiNameController.clear();
                          _apiUrlController.clear();
                          _apiDetailController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF3D3D3D)
                              : const Color(0xFFE0E0E0),
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}