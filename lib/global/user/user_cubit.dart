import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/model/entities/user_entity.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  void setUser(UserEntity user) {
    emit(UserLoaded(user));
  }

  void clearUser() {
    emit(UserInitial());
  }
}
