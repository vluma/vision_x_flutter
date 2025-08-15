import 'package:flutter/material.dart';
import 'colors.dart';

class ThemeExample extends StatelessWidget {
  const ThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题色表示例',
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            
            // 主要按钮颜色示例
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('按钮颜色', style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('主要按钮'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text('次要按钮'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // 状态颜色示例
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态颜色', style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusColorBox(AppColors.success, '成功'),
                      _buildStatusColorBox(AppColors.warning, '警告'),
                      _buildStatusColorBox(AppColors.error, '错误'),
                      _buildStatusColorBox(AppColors.info, '信息'),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // 文字颜色示例
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('文字颜色', style: theme.textTheme.titleMedium),
                  SizedBox(height: 8),
                  Text(
                    '主要文字颜色',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                  ),
                  Text(
                    '次要文字颜色',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusColorBox(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}