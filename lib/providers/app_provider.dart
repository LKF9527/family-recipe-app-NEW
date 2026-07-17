import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/member.dart';
import '../services/database_service.dart';

/// 应用全局状态管理Provider
class AppProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  User? _user;
  List<Member> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOwner => _user?.isOwner ?? false;

  // 获取家庭名称
  String get familyName => _user?.family ?? '未命名家庭';

  // 获取成员数量
  int get memberCount => _members.length;

  // 获取群主
  Member? get owner {
    try {
      return _members.firstWhere((member) => member.isOwner);
    } catch (e) {
      return null;
    }
  }

  /// 初始化应用数据
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadUser();
      await _loadMembers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '加载用户数据失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载用户数据
  Future<void> _loadUser() async {
    _user = await _dbService.getUser();
    notifyListeners();
  }

  /// 加载成员数据
  Future<void> _loadMembers() async {
    _members = await _dbService.getMembers();
    notifyListeners();
  }

  /// 切换用户角色（演示功能）
  Future<void> toggleUserRole() async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      role: _user!.role == 'owner' ? 'member' : 'owner',
    );

    await _dbService.updateUser(updatedUser);
    _user = updatedUser;

    notifyListeners();
  }

  /// 更新用户信息
  Future<void> updateUser(User user) async {
    try {
      await _dbService.updateUser(user);
      _user = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = '更新用户信息失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 添加成员
  Future<void> addMember(Member member) async {
    try {
      await _dbService.insertMember(member);
      await _loadMembers();
      notifyListeners();
    } catch (e) {
      _errorMessage = '添加成员失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 移除成员
  Future<void> removeMember(String memberId) async {
    try {
      // 不能移除群主
      if (memberId == 'm1') {
        _errorMessage = '不能移除群主';
        notifyListeners();
        return;
      }

      await _dbService.deleteMember(memberId);
      await _loadMembers();
      notifyListeners();
    } catch (e) {
      _errorMessage = '移除成员失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 解散家庭（演示功能）
  Future<void> dismissFamily() async {
    try {
      // 在实际应用中，这里会有更多的逻辑
      // 目前只是重置为默认成员
      await _resetMembers();
      notifyListeners();
    } catch (e) {
      _errorMessage = '解散家庭失败: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 重置成员数据
  Future<void> _resetMembers() async {
    final defaultMembers = [
      Member(id: 'm1', name: '林小满', role: '创建者', avatar: '林', color: '#e79c75'),
    ];

    // 清空现有成员
    for (var member in _members) {
      if (member.id != 'm1') {
        await _dbService.deleteMember(member.id);
      }
    }

    await _loadMembers();
  }

  /// 获取邀请码（演示功能）
  String getInviteCode() {
    return 'XM2026'; // 硬编码的邀请码
  }

  /// 根据ID获取成员
  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await initialize();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}