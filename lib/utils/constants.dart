import 'package:flutter/material.dart';

/// 应用常量配置
class AppConstants {
  // 应用信息
  static const String appName = '家的味道';
  static const String appVersion = '1.0.0';
  static const String fontFamily = 'System';

  // Material Design 3 颜色主题
  static const Color primaryColor = Color(0xFF43785B); // 深鼠尾草绿
  static const Color primaryContainer = Color(0xFFE4EEE7);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondaryColor = Color(0xFF7B9F87);
  static const Color secondaryContainer = Color(0xFFD4E7D9);

  static const Color backgroundColor = Color(0xFFF7F5EF); // 温暖米白色
  static const Color cardColor = Color(0xFFFFFDF8); // 奶油色

  static const Color textPrimary = Color(0xFF28342D); // 深炭色
  static const Color textSecondary = Color(0xFF8B918C); // 灰色

  static const Color errorColor = Color(0xFFB86255); // 陶土红
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color outlineColor = Color(0xFFD0D4CF);
  static const Color surfaceVariant = Color(0xFFE3E8DF);

  // 菜谱分类颜色
  static const Map<String, Color> categoryColors = {
    'c1': Color(0xFFF8D4C5), // 家常菜
    'c2': Color(0xFFF4E3AD), // 汤羹
    'c3': Color(0xFFDFCFB8), // 主食
    'c4': Color(0xFFDCE7C4), // 轻食
  };

  // 成员颜色
  static const Map<String, Color> memberColors = {
    'm1': Color(0xFFE79C75), // 林小满
    'm2': Color(0xFF7B9F87), // 陈先生
    'm3': Color(0xFFC69C74), // 奶奶
  };

  // 阴影
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F384739),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Color(0x1A43785B),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 28.0;
  static const double radiusXLarge = 40.0;

  // 间距
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // 字体大小
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;

  // 图标大小
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // 动画时长
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Tab配置
  static const List<TabInfo> tabs = [
    TabInfo(
      index: 0,
      title: '菜谱',
      icon: Icons.restaurant_menu,
      route: '/home',
    ),
    TabInfo(
      index: 1,
      title: '菜单',
      icon: Icons.calendar_today,
      route: '/menu',
    ),
    TabInfo(
      index: 2,
      title: '家庭',
      icon: Icons.people,
      route: '/family',
    ),
    TabInfo(
      index: 3,
      title: '我的',
      icon: Icons.person,
      route: '/profile',
    ),
  ];

  // 表单验证
  static const int maxRecipeNameLength = 50;
  static const int maxDescLength = 200;
  static const int maxIngredientsCount = 20;
  static const int maxStepsCount = 20;

  // 图片配置
  static const double maxImageSize = 5.0; // MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];

  // 日期格式
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateDisplayFormat = 'MM月dd日';
  static const String weekdayFormat = 'EEEE';

  // 数据库
  static const String databaseName = 'family_recipe.db';
  static const int databaseVersion = 1;

  // 邀请码（演示用）
  static const String inviteCode = 'XM2026';

  // AI功能相关（已移除）
  static const bool aiFeatureEnabled = false;
  static const int maxTextInputLength = 8000;
}

/// Tab信息类
class TabInfo {
  final int index;
  final String title;
  final IconData icon;
  final String route;

  const TabInfo({
    required this.index,
    required this.title,
    required this.icon,
    required this.route,
  });
}