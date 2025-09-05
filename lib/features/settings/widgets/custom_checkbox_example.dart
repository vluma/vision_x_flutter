import 'package:flutter/material.dart';
import 'custom_checkbox.dart';

/// 自定义复选框使用示例
class CustomCheckboxExample extends StatefulWidget {
  const CustomCheckboxExample({super.key});

  @override
  State<CustomCheckboxExample> createState() => _CustomCheckboxExampleState();
}

class _CustomCheckboxExampleState extends State<CustomCheckboxExample> {
  final Map<String, bool> _checkboxStates = {
    'option1': false,
    'option2': true,
    'option3': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义复选框示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择你喜欢的选项：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomCheckbox(
              value: _checkboxStates['option1']!,
              onChanged: (value) {
                setState(() {
                  _checkboxStates['option1'] = value ?? false;
                });
              },
              label: '选项一',
            ),
            const SizedBox(height: 12),
            CustomCheckbox(
              value: _checkboxStates['option2']!,
              onChanged: (value) {
                setState(() {
                  _checkboxStates['option2'] = value ?? false;
                });
              },
              label: '选项二',
              activeColor: Colors.green,
            ),
            const SizedBox(height: 12),
            CustomCheckbox(
              value: _checkboxStates['option3']!,
              onChanged: (value) {
                setState(() {
                  _checkboxStates['option3'] = value ?? false;
                });
              },
              label: '选项三',
              size: 24.0,
              activeColor: Colors.red,
            ),
            const SizedBox(height: 30),
            const Text(
              '当前选择状态：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),n            const SizedBox(height: 10),
            ..._checkboxStates.entries.map((entry) => Text(
                  '${entry.key}: ${entry.value ? "已选择" : "未选择"}',
                  style: const TextStyle(fontSize: 14),
                )),
          ],
        ),
      ),
    );
  }
}