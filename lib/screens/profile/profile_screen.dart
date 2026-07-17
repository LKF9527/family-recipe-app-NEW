import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

/// 个人中心页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = appProvider.user;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // 用户信息卡片
                _buildUserCard(context, user, appProvider),

                SizedBox(height: AppConstants.paddingMedium),

                // 功能列表
                _buildFunctionList(context, appProvider),

                SizedBox(height: AppConstants.paddingMedium),

                // 设置卡片
                _buildSettingsCard(context, appProvider),

                SizedBox(height: AppConstants.paddingXLarge),

                // 版本信息
                _buildVersionInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('我的'),
    );
  }

  /// 构建用户卡片
  Widget _buildUserCard(BuildContext context, dynamic user, AppProvider appProvider) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 32,
              backgroundColor: AppConstants.primaryColor,
              child: Text(
                user?.avatar ?? '用',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: AppConstants.paddingMedium),

            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user?.name ?? '未知用户',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(width: AppConstants.paddingSmall),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: appProvider.isOwner
                              ? AppConstants.primaryContainer
                              : AppConstants.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          appProvider.isOwner ? '家庭创建者' : '家庭成员',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: appProvider.isOwner
                                    ? AppConstants.primaryColor
                                    : AppConstants.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.paddingXSmall),
                  Text(
                    user?.family ?? '未设置家庭',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // 编辑按钮
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // 可以添加编辑用户信息功能
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能列表
  Widget _buildFunctionList(BuildContext context, AppProvider appProvider) {
    return Card(
      child: Column(
        children: [
          _buildFunctionItem(
            context,
            icon: Icons.favorite_border,
            title: '我的收藏',
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          Divider(height: 1),
          _buildFunctionItem(
            context,
            icon: Icons.people,
            title: '家庭管理',
            onTap: () {
              // 切换到家庭Tab
              // 这里可以通过全局状态切换Tab
            },
          ),
          Divider(height: 1),
          _buildFunctionItem(
            context,
            icon: Icons.cloud_outlined,
            title: '云端同步',
            trailing: Text(
              '正常',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.primaryColor,
                  ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据同步正常')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建功能项
  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor),
            SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (trailing != null) trailing,
            const Icon(Icons.chevron_right, color: AppConstants.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 构建设置卡片
  Widget _buildSettingsCard(BuildContext context, AppProvider appProvider) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            child: Text(
              '设置',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
          ),
          _buildSettingItem(
            context,
            title: '角色权限演示',
            subtitle: appProvider.isOwner ? '当前：群主' : '当前：成员',
            onTap: () async {
              await appProvider.toggleUserRole();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appProvider.isOwner ? '已切换为群主' : '已切换为成员'),
                  ),
                );
              }
            },
          ),
          Divider(height: 1),
          _buildSettingItem(
            context,
            title: '应用设置',
            subtitle: '主题、通知等设置',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能开发中')),
              );
            },
          ),
          Divider(height: 1),
          _buildSettingItem(
            context,
            title: '关于应用',
            subtitle: '版本信息和开发者',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppConstants.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 构建版本信息
  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          AppConstants.appName,
          style: TextStyle(
            color: AppConstants.textSecondary,
            fontSize: AppConstants.fontSizeSmall,
          ),
        ),
        Text(
          'v${AppConstants.appVersion}',
          style: TextStyle(
            color: AppConstants.textSecondary,
            fontSize: AppConstants.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于应用'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppConstants.paddingSmall),
            Text('版本: v${AppConstants.appVersion}'),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              '一个简单的家庭菜谱管理应用',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}