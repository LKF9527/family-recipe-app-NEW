import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/recipe.dart';
import '../models/category.dart';
import '../providers/recipe_provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'package:uuid/uuid.dart';

/// 菜谱编辑页面
class EditorScreen extends StatefulWidget {
  final String? recipeId;

  const EditorScreen({super.key, this.recipeId});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  List<Category> _categories = [];
  String? _selectedCategoryId;
  String? _coverPath;
  String _emoji = '🍳';
  String _color = '#cccccc';
  List<IngredientItem> _ingredients = [];
  List<IngredientItem> _seasonings = [];
  List<String> _steps = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // 可用的emoji列表
  final List<String> _availableEmojis = [
    '🍳', '🍲', '🍜', '🍝', '🍱', '🍘', '🍙', '🍚', '🍛', '🍢',
    '🍣', '🍤', '🍥', '🍡', '🥟', '🥠', '🥡', '🥘', '🍲', '🍛',
    '🍗', '🍖', '🍕', '🌭', '🍔', '🍟', '🥙', '🥪', '🌮', '🌯',
    '🥗', '🥬', '🥒', '🌽', '🥕', '🥔', '🍠', '🍆', '🍅', '🥝',
  ];

  // 可用的颜色列表
  final List<String> _availableColors = [
    '#f8d4c5', '#e9c5ad', '#d5e7ca', '#f4e3ad',
    '#dfcfb8', '#dce7c4', '#e8d4b8', '#d4e7ca',
    '#c9deb0', '#b8d4e7', '#d4b8e7', '#e7d4b8',
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _initializeData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// 检查权限
  void _checkPermission() {
    final appProvider = context.read<AppProvider>();
    if (!appProvider.isOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无管理权限')),
        );
      });
    }
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipeProvider = context.read<RecipeProvider>();
      _categories = recipeProvider.categories;

      // 如果是编辑模式，加载现有数据
      if (widget.recipeId != null) {
        final recipe = recipeProvider.getRecipeById(widget.recipeId!);
        if (recipe != null) {
          _nameController.text = recipe.name;
          _descController.text = recipe.desc;
          _selectedCategoryId = recipe.categoryId;
          _coverPath = recipe.coverPath;
          _emoji = recipe.emoji;
          _color = recipe.color;
          _ingredients = recipe.ingredients;
          _seasonings = recipe.seasonings;
          _steps = recipe.steps;
        } else {
          // 设置默认分类
          _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
        }
      } else {
        // 新建模式，设置默认值
        _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
        _ingredients = [IngredientItem(name: '', amount: '')];
        _seasonings = [IngredientItem(name: '', amount: '')];
        _steps = [''];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              _buildBasicInfo(context),

              SizedBox(height: AppConstants.paddingLarge),

              // 分类和封面
              _buildCategoryAndCover(context),

              SizedBox(height: AppConstants.paddingLarge),

              // Emoji和颜色
              _buildEmojiAndColor(context),

              SizedBox(height: AppConstants.paddingLarge),

              // 食材
              _buildIngredientsSection(context),

              SizedBox(height: AppConstants.paddingLarge),

              // 调料
              _buildSeasoningsSection(context),

              SizedBox(height: AppConstants.paddingLarge),

              // 步骤
              _buildStepsSection(context),

              SizedBox(height: AppConstants.paddingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建应用栏
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.recipeId != null ? '编辑菜谱' : '新建菜谱'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (!_isSaving)
          TextButton(
            onPressed: () => _saveRecipe(context),
            child: const Text('保存'),
          )
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  /// 构建基本信息
  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本信息',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppConstants.paddingMedium),

        // 名称
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '菜谱名称',
            hintText: '请输入菜谱名称',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入菜谱名称';
            }
            return null;
          },
        ),

        SizedBox(height: AppConstants.paddingMedium),

        // 描述
        TextFormField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: '描述',
            hintText: '请输入菜谱描述',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入菜谱描述';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 构建分类和封面
  Widget _buildCategoryAndCover(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类和封面',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppConstants.paddingMedium),

        // 分类选择
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: '分类',
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请选择分类';
            }
            return null;
          },
        ),

        SizedBox(height: AppConstants.paddingMedium),

        // 封面上传
        _buildCoverUploader(context),
      ],
    );
  }

  /// 构建封面上传器
  Widget _buildCoverUploader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '封面图片',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: AppConstants.paddingSmall),
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: AppConstants.outlineColor),
            ),
            child: _coverPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: Image.asset(
                      _coverPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildUploadPlaceholder();
                      },
                    ),
                  )
                : _buildUploadPlaceholder(),
          ),
        ),
      ],
    );
  }

  /// 构建上传占位符
  Widget _buildUploadPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: AppConstants.iconSizeLarge,
            color: AppConstants.textSecondary,
          ),
          SizedBox(height: AppConstants.paddingXSmall),
          Text(
            '点击上传封面',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建Emoji和颜色选择
  Widget _buildEmojiAndColor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '图标和颜色',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: AppConstants.paddingMedium),

        // Emoji选择
        Text(
          '选择图标',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: AppConstants.paddingSmall),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _availableEmojis[index];
              final isSelected = emoji == _emoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _emoji = emoji;
                  });
                },
                child: Container(
                  width: 50,
                  margin: EdgeInsets.only(right: AppConstants.paddingXSmall),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryContainer
                        : AppConstants.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : AppConstants.outlineColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: AppConstants.paddingMedium),

        // 颜色选择
        Text(
          '选择颜色',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: AppConstants.paddingSmall),
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = color == _color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _color = color;
                  });
                },
                child: Container(
                  width: 40,
                  margin: EdgeInsets.only(right: AppConstants.paddingXSmall),
                  decoration: BoxDecoration(
                    color: _parseColor(color),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : AppConstants.outlineColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建食材部分
  Widget _buildIngredientsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '食材',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton.icon(
              onPressed: () => _addIngredient(),
              icon: const Icon(Icons.add),
              label: const Text('添加食材'),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingMedium),
        ...List.generate(_ingredients.length, (index) {
          return _buildIngredientItem(index, true);
        }),
      ],
    );
  }

  /// 构建食材项
  Widget _buildIngredientItem(int index, bool isIngredient) {
    final items = isIngredient ? _ingredients : _seasonings;
    final item = items[index];

    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: item.name,
              decoration: InputDecoration(
                labelText: isIngredient ? '食材名称' : '调料名称',
              ),
              onChanged: (value) {
                setState(() {
                  items[index] = IngredientItem(name: value, amount: item.amount);
                });
              },
            ),
          ),
          SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: TextFormField(
              initialValue: item.amount,
              decoration: InputDecoration(
                labelText: '用量',
              ),
              onChanged: (value) {
                setState(() {
                  items[index] = IngredientItem(name: item.name, amount: value);
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => _removeItem(index, isIngredient),
          ),
        ],
      ),
    );
  }

  /// 构建调料部分
  Widget _buildSeasoningsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '调料',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton.icon(
              onPressed: () => _addSeasoning(),
              icon: const Icon(Icons.add),
              label: const Text('添加调料'),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingMedium),
        ...List.generate(_seasonings.length, (index) {
          return _buildIngredientItem(index, false);
        }),
      ],
    );
  }

  /// 构建步骤部分
  Widget _buildStepsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '步骤',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton.icon(
              onPressed: () => _addStep(),
              icon: const Icon(Icons.add),
              label: const Text('添加步骤'),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingMedium),
        ...List.generate(_steps.length, (index) {
          return _buildStepItem(index);
        }),
      ],
    );
  }

  /// 构建步骤项
  Widget _buildStepItem(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤编号
          Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.only(top: AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SizedBox(width: AppConstants.paddingSmall),

          // 步骤内容
          Expanded(
            child: TextFormField(
              initialValue: _steps[index],
              decoration: InputDecoration(
                labelText: '步骤 ${index + 1}',
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _steps[index] = value;
                });
              },
            ),
          ),

          // 删除按钮
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => _removeStep(index),
          ),
        ],
      ),
    );
  }

  /// 添加食材
  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientItem(name: '', amount: ''));
    });
  }

  /// 添加调料
  void _addSeasoning() {
    setState(() {
      _seasonings.add(IngredientItem(name: '', amount: ''));
    });
  }

  /// 添加步骤
  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  /// 移除食材/调料
  void _removeItem(int index, bool isIngredient) {
    setState(() {
      if (isIngredient && _ingredients.length > 1) {
        _ingredients.removeAt(index);
      } else if (!isIngredient && _seasonings.length > 1) {
        _seasonings.removeAt(index);
      }
    });
  }

  /// 移除步骤
  void _removeStep(int index) {
    setState(() {
      if (_steps.length > 1) {
        _steps.removeAt(index);
      }
    });
  }

  /// 选择图片
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _coverPath = pickedFile.path;
      });
    }
  }

  /// 解析颜色
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppConstants.categoryColors.values.first;
    }
  }

  /// 保存菜谱
  Future<void> _saveRecipe(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证食材、调料和步骤
    final validIngredients = _ingredients.where((item) => item.name.trim().isNotEmpty).toList();
    final validSeasonings = _seasonings.where((item) => item.name.trim().isNotEmpty).toList();
    final validSteps = _steps.where((step) => step.trim().isNotEmpty).toList();

    if (validIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一个食材')),
      );
      return;
    }

    if (validSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一个步骤')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final recipeProvider = context.read<RecipeProvider>();
      final recipe = Recipe(
        id: widget.recipeId ?? 'r${DateTime.now().millisecondsSinceEpoch}',
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        desc: _descController.text.trim(),
        emoji: _emoji,
        color: _color,
        coverPath: _coverPath,
        ingredients: validIngredients,
        seasonings: validSeasonings,
        steps: validSteps,
        favorite: false,
      );

      if (widget.recipeId != null) {
        // 编辑模式
        await recipeProvider.updateRecipe(recipe);
      } else {
        // 新建模式
        await recipeProvider.addRecipe(recipe);
      }

      if (mounted) {
        // 返回并刷新数据
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipeId != null ? '菜谱已更新' : '菜谱已创建'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}