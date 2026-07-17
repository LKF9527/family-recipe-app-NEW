# 家的味道 - Flutter安卓应用

## 项目概述

这是一个从微信小程序转换而来的Flutter安卓应用，用于家庭菜谱管理。应用采用Material Design 3设计风格，使用本地SQLite数据库存储数据，不需要云端服务。

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **状态管理**: Provider
- **本地存储**: SQLite (sqflite)
- **设计风格**: Material Design 3

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── models/                        # 数据模型
│   │   ├── recipe.dart               # 菜谱模型
│   │   ├── category.dart             # 分类模型
│   │   ├── menu.dart                 # 菜单模型
│   │   ├── member.dart               # 成员模型
│   │   └── user.dart                 # 用户模型
│   ├── providers/                     # 状态管理
│   │   ├── recipe_provider.dart      # 菜谱状态管理
│   │   ├── app_provider.dart         # 应用全局状态
│   │   └── menu_provider.dart        # 菜单状态管理
│   ├── screens/                       # 页面
│   │   ├── home/home_screen.dart     # 首页-菜谱浏览
│   │   ├── detail/detail_screen.dart # 菜谱详情
│   │   ├── editor/editor_screen.dart # 菜谱编辑
│   │   ├── menu/menu_screen.dart     # 菜单规划
│   │   ├── family/family_screen.dart # 家庭管理
│   │   ├── profile/profile_screen.dart # 个人中心
│   │   └── favorites/favorites_screen.dart # 收藏页面
│   ├── widgets/                       # 自定义组件
│   │   └── recipe_card.dart         # 菜谱卡片组件
│   ├── services/                      # 服务层
│   │   ├── database_service.dart    # 数据库服务
│   │   └── data_migration_service.dart # 数据迁移服务
│   └── utils/                         # 工具类
│       └── constants.dart             # 常量配置
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

## 功能特性

### 已实现功能

1. **首页 (菜谱浏览)**
   - 菜谱分类浏览
   - 实时搜索功能
   - 菜谱卡片展示
   - 快速添加到菜单
   - 收藏快捷入口

2. **菜谱详情**
   - 完整的菜谱信息展示
   - 食材和调料列表
   - 步骤说明
   - 收藏功能
   - 添加到菜单功能
   - 编辑和删除功能（群主权限）

3. **菜谱编辑**
   - 新建和编辑菜谱
   - 分类选择
   - 封面上传
   - 图标和颜色自定义
   - 食材、调料、步骤编辑
   - 动态添加/删除项目

4. **菜单规划**
   - 三种视图模式：日视图、周视图、月视图
   - 日期选择和导航
   - 菜谱管理（添加/移除）
   - 菜谱数量统计
   - 空状态提示

5. **家庭管理**
   - 成员列表展示
   - 邀请功能（演示）
   - 移除成员功能（群主权限）
   - 角色显示

6. **个人中心**
   - 用户信息展示
   - 功能导航
   - 角色权限切换演示
   - 应用设置

7. **收藏页面**
   - 收藏菜谱网格展示
   - 快速访问菜谱详情

### 技术特性

- **本地数据存储**: 使用SQLite数据库，支持离线使用
- **数据迁移**: 自动将微信小程序数据迁移到Flutter应用
- **状态管理**: Provider架构，响应式UI更新
- **权限控制**: 基于角色的访问控制（群主/成员）
- **Material Design 3**: 现代化UI设计
- **响应式布局**: 适配不同屏幕尺寸

## 安装和运行

### 前置要求

- Flutter SDK 3.0+
- Dart SDK
- Android Studio / VS Code
- Android模拟器或真机

### 安装步骤

1. **克隆项目**
```bash
cd flutter_app
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
flutter run
```

4. **构建APK**
```bash
flutter build apk --release
```

## 使用指南

### 首次使用

应用首次启动时会自动初始化以下数据：

- **4个菜谱分类**: 家常菜、汤羹、主食、轻食
- **6个示例菜谱**: 番茄炒蛋、可乐鸡翅、清炒西兰花、玉米排骨汤、香菇鸡肉焖饭、鲜虾牛油果沙拉
- **3个家庭成员**: 林小满（群主）、陈先生、奶奶
- **默认用户**: 林小满，群主权限

### 基本操作

1. **浏览菜谱**
   - 在首页左侧选择分类
   - 使用顶部搜索栏搜索菜谱
   - 点击菜谱卡片查看详情

2. **管理菜谱**
   - 点击右下角"+"按钮新建菜谱（群主权限）
   - 在详情页点击"编辑"修改菜谱（群主权限）
   - 点击"收藏"按钮收藏菜谱

3. **规划菜单**
   - 在首页点击菜谱卡片的"+"快速添加
   - 在详情页点击"加入菜单"选择日期
   - 在菜单页面查看和管理日程安排

4. **家庭管理**
   - 在个人中心切换到家庭页面
   - 点击"邀请家人"获取邀请码（演示）
   - 移除家庭成员（群主权限）

### 权限说明

应用支持两种用户角色：

- **群主（创建者）**: 
  - 新建和编辑菜谱
  - 删除菜谱
  - 管理家庭成员
  - 清空菜单

- **成员**: 
  - 查看菜谱
  - 收藏菜谱
  - 添加到菜单
  - 查看家庭信息

可以在个人中心切换角色进行演示。

## 数据迁移

应用包含数据迁移服务，可以将微信小程序的数据自动转换为Flutter格式：

```dart
import 'package:flutter_app/services/data_migration_service.dart';

// 执行数据迁移
final migrationService = DataMigrationService();
await migrationService.migrateData();
```

## 配置选项

### 颜色主题

在`lib/utils/constants.dart`中可以修改应用的颜色配置：

```dart
static const Color primaryColor = Color(0xFF43785B);  // 主色调
static const Color backgroundColor = Color(0xFFF7F5EF); // 背景色
```

### 功能开关

```dart
static const bool aiFeatureEnabled = false;  // AI功能（已移除）
```

## 开发指南

### 添加新功能

1. 在`lib/models/`中创建数据模型
2. 在`lib/providers/`中创建状态管理
3. 在`lib/screens/`中创建页面
4. 在`lib/widgets/`中创建可复用组件
5. 在`main.dart`中注册路由

### 数据库操作

使用`DatabaseService`进行数据操作：

```dart
final dbService = DatabaseService();

// 查询所有菜谱
final recipes = await dbService.getRecipes();

// 添加菜谱
await dbService.insertRecipe(recipe);

// 更新菜谱
await dbService.updateRecipe(recipe);

// 删除菜谱
await dbService.deleteRecipe(recipeId);
```

### 状态管理

使用Provider进行状态管理：

```dart
// 读取状态
final recipeProvider = context.watch<RecipeProvider>();
final recipes = recipeProvider.recipes;

// 更新状态
recipeProvider.selectCategory(categoryId);
await recipeProvider.addRecipe(recipe);
```

## 常见问题

### 1. 数据丢失怎么办？

应用数据存储在本地SQLite数据库中，卸载应用会丢失数据。建议定期导出数据（功能开发中）。

### 2. 如何同步数据？

当前版本不支持云端同步，所有数据存储在本地。如需多设备同步，需要自行实现云存储功能。

### 3. 图片存储在哪里？

菜谱封面图片存储在设备本地文件系统中，引用路径保存在数据库中。

### 4. 如何重置应用数据？

在应用设置中会有"重置数据"选项，或者重新安装应用。

## 性能优化

- 使用`const`构造函数减少重建
- 图片懒加载和缓存
- 列表使用`ListView.builder`进行虚拟化
- 状态管理采用精细更新策略

## 已知限制

1. **AI功能**: 已移除云端的AI菜谱识别功能
2. **云端同步**: 不支持多设备数据同步
3. **图片上传**: 仅支持本地相册，不支持相机拍摄
4. **导出功能**: 暂不支持数据导出

## 未来计划

- [ ] 添加数据导出/导入功能
- [ ] 支持相机拍摄菜谱封面
- [ ] 添加购物车功能
- [ ] 实现菜谱分享功能
- [ ] 添加烹饪计时器
- [ ] 支持云端数据同步
- [ ] 添加菜谱评分和评论

## 技术支持

如有问题或建议，请联系开发者。

## 许可证

本项目基于微信小程序"家的味道"进行Flutter实现，保持原有功能和设计风格。

---

**版本**: v1.0.0  
**更新日期**: 2026-07-17  
**开发者**: AI Assistant