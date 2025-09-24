/// 导航模块入口文件
/// 导出导航模块的所有公共API
library;

// 模型层
export 'models/nav_bar_constants.dart';

// 状态层
export 'states/navigation_state.dart';

// 提供者层
export 'providers/navigation_provider.dart';

// 视图模型层
export 'viewmodels/navigation_view_model.dart';

// 视图层
export 'views/bottom_navigation_bar.dart';

// 组件层
export 'views/widgets/nav_button.dart';
export 'views/widgets/search_button.dart';
export 'views/widgets/menu_button.dart';
export 'views/widgets/search_field.dart';
export 'views/widgets/navigation_container.dart';
export 'views/widgets/search_container.dart';