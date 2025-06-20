import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/global/auth/auth_cubit.dart';
import 'package:todo_app/ui/views/todo/todo_cubit.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';
import 'package:todo_app/ui/views/widgets/category_selector_widget.dart';
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

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  TodoCategory _selectedCategory = TodoCategory.personal;

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
    _selectedDate = todo.date;
    _selectedTime = todo.time != null
        ? TimeOfDay.fromDateTime(todo.time!)
        : null;
    _selectedCategory = todo.category;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildForm()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            isEditing ? 'Edit Task' : 'Add New Task',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter task title',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Category Selector
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CategorySelectorWidget(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          const SizedBox(height: 24),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 12),
                            Text(AppDateUtils.formatDate(_selectedDate)),
                          ],
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
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 12),
                            Text(_selectedTime?.format(context) ?? 'Time'),
                          ],
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
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Add notes (optional)',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTodo,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

  void _saveTodo() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final DateTime? dateTime = _selectedTime != null
        ? DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
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

      context.read<TodoCubit>().updateTodo(widget.todo!.id, params);
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

      context.read<TodoCubit>().createTodo(params);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
