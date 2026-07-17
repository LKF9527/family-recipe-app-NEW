import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';

/// 家庭管理页面
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 主视觉区域
              _buildHeroSection(context, appProvider),

              // 成员列表
              Expanded(
                child: _buildMembersList(context, appProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('家庭管理'),
    );
  }

  /// 构建主视觉区域
  Widget _buildHeroSection(BuildContext context, AppProvider appProvider) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryContainer,
            AppConstants.cardColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // 家庭名称
          Text(
            appProvider.familyName,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppConstants.primaryColor,
                ),
          ),

          SizedBox(height: AppConstants.paddingMedium),

          // 统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(context, '${appProvider.memberCount}', '成员'),
              SizedBox(width: AppConstants.paddingXLarge),
              _buildStatItem(context, '6', '菜谱'),
            ],
          ),

          SizedBox(height: AppConstants.paddingMedium),

          // 邀请按钮（仅群主）
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (!appProvider.isOwner) {
                return const SizedBox.shrink();
              }

              return ElevatedButton.icon(
                onPressed: () => _showInviteDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('邀请家人'),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.textSecondary,
              ),
        ),
      ],
    );
  }

  /// 构建成员列表
  Widget _buildMembersList(BuildContext context, AppProvider appProvider) {
    final members = appProvider.members;

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: AppConstants.iconSizeXLarge,
              color: AppConstants.textSecondary,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              '暂无家庭成员',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberTile(context, member, appProvider);
      },
    );
  }

  /// 构建成员项
  Widget _buildMemberTile(BuildContext context, dynamic member, AppProvider appProvider) {
    final isOwner = member.isOwner;
    final canRemove = appProvider.isOwner && !isOwner;

    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(member.color),
          child: Text(
            member.avatar,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(member.name),
            if (isOwner) ...[
              SizedBox(width: AppConstants.paddingSmall),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Text(
                  '群主',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(member.role),
        trailing: canRemove
            ? IconButton(
                icon: const Icon(Icons.remove_circle),
                color: AppConstants.errorColor,
                onPressed: () => _showRemoveDialog(context, member),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  /// 显示邀请对话框
  void _showInviteDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final inviteCode = appProvider.getInviteCode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('邀请家人'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分享邀请码给家人，让他们加入：',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      inviteCode,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('邀请码已复制到剪贴板')),
                      );
                    },
                  ),
                ],
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

  /// 显示移除对话框
  void _showRemoveDialog(BuildContext context, dynamic member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除成员'),
        content: Text('确定要移除 ${member.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final appProvider = context.read<AppProvider>();
              await appProvider.removeMember(member.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member.name} 已移除')),
                );
              }
            },
            child: const Text('确定'),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 解析颜色
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF7B9F87);
    }
  }
}