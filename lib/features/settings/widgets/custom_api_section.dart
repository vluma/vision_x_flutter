import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/spacing.dart';
import '../settings_controller.dart';

class CustomApiSection extends StatefulWidget {
  const CustomApiSection({super.key});

  @override
  State<CustomApiSection> createState() => _CustomApiSectionState();
}

class _CustomApiSectionState extends State<CustomApiSection> {
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
    final controller = Provider.of<SettingsController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: isDark ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自定义API',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: controller.showAddCustomApiForm,
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
              ],
            ),
            const SizedBox(height: 12),
            // 自定义API列表
            if (controller.customApis.isNotEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: controller.customApis.length,
                  itemBuilder: (context, index) {
                    final api = controller.customApis[index];
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
                        onPressed: () => controller.removeCustomApi(index, context),
                      ),
                    );
                  },
                ),
              ),
            // 添加自定义API表单
            if (controller.showCustomApiForm) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _apiNameController,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'API名称',
                        labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiUrlController,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'https://abc.com',
                        labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiDetailController,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'detail地址（可选）',
                        labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 隐藏资源站复选框
                    Row(
                      children: [
                        Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: controller.isHiddenSource,
                          onChanged: (bool? value) {
                            controller.updateIsHiddenSource(value ?? false);
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
                            controller.addCustomApi(
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
                            controller.cancelAddCustomApi();
                            _apiNameController.clear();
                            _apiUrlController.clear();
                            _apiDetailController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF3D3D3D)
                                : const Color(0xFFE0E0E0),
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black87,
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
      ),
    );
  }
}