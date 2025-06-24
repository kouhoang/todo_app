import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/global/auth/auth_cubit.dart';
import 'package:todo_app/ui/views/todo/todo_cubit.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';
import 'package:todo_app/ui/widgets/category_selector_widget.dart';
import 'package:todo_app/utils/date_utils.dart';

class AddTodoView extends StatefulWidget {
  final TodoEntity? todo;

  const AddTodoView({super.key, this.todo});

  @override
  State<AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate; // Changed to nullable
  TimeOfDay? _selectedTime;
  TodoCategory _selectedCategory = TodoCategory.list;
  bool _isLoading = false;

  bool get isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeWithTodo(widget.todo!);
    }
  }

  void _initializeWithTodo(TodoEntity todo) {
    _titleController.text = todo.title;
    _notesController.text = todo.notes ?? '';
    _selectedDate = todo.date; // Can be null
    _selectedTime = todo.time != null
        ? TimeOfDay.fromDateTime(todo.time!)
        : null;
    _selectedCategory = todo.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildForm()),
              _buildSaveButton(),
            ],
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(color: AppColors.secondary),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/ellipse_2.png', fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset('assets/ellipse_1.png', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 40,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pop(context, false),
                icon: Icon(Icons.close, color: AppColors.primary, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Center(
            child: Text(
              isEditing ? 'Edit Task' : 'Add New Task',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      color: AppColors.background,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title Field
            Text(
              'Task Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE0E0E0), width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              child: TextFormField(
                controller: _titleController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 24),

            // Category Selector
            CategorySelectorWidget(
              selectedCategory: _selectedCategory,
              onCategorySelected: _isLoading
                  ? null
                  : (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
              isEnabled: !_isLoading,
            ),

            const SizedBox(height: 24),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isLoading
                              ? Colors.grey[400]
                              : AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: _isLoading ? null : _selectDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  _selectedDate != null
                                      ? AppDateUtils.formatDate(_selectedDate!)
                                      : 'Date',
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: _isLoading
                                      ? Colors.grey[400]
                                      : AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isLoading
                              ? Colors.grey[400]
                              : AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: _isLoading ? null : _selectTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  _selectedTime?.format(context) ?? 'Time',
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: _isLoading
                                      ? Colors.grey[400]
                                      : AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notes Field
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isLoading ? Colors.grey[400] : AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              child: TextFormField(
                controller: _notesController,
                enabled: !_isLoading,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Notes',
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 16,
      ),
      color: AppColors.background,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey[400] : AppColors.secondary,
          borderRadius: BorderRadius.circular(36),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveTodo,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isLoading
                ? Colors.grey[400]
                : AppColors.secondary,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            disabledBackgroundColor: Colors.grey[400],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing ? 'Update' : 'Save',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Use current date if null
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final DateTime? dateTime = _selectedTime != null && _selectedDate != null
          ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
          : null;

      if (isEditing) {
        final params = UpdateTodoParams(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _selectedDate,
          time: dateTime,
          category: _selectedCategory,
        );

        await context.read<TodoCubit>().updateTodo(widget.todo!.id, params);
      } else {
        final params = CreateTodoParams(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _selectedDate,
          time: dateTime,
          category: _selectedCategory,
          userId: authState.user.id,
        );

        await context.read<TodoCubit>().createTodo(params);
      }

      if (mounted) {
        _showSuccessMessage(
          isEditing
              ? 'Task updated successfully!'
              : 'Task created successfully!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage(
          'Failed to ${isEditing ? 'update' : 'create'} task. Please try again.',
        );
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
