import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final double size;
  final Color activeColor;
  final Color checkColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.size = 20.0,
    this.activeColor = const Color(0xFF2196F3),
    this.checkColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 复选框
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: value ? activeColor : Colors.transparent,
                border: Border.all(
                  color: value ? activeColor : Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: [
                  if (value)
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: size * 0.7,
                      color: checkColor,
                    )
                  : null,
            ),
            const SizedBox(width: 12.0),
            // 标签
            Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}