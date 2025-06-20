import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/model/entities/user_entity.dart';
import '../../repositories/user_repository.dart';
import '../../utils/device_utils.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepository = UserRepository();

  AuthCubit() : super(AuthInitial());

  Future<void> initializeUser() async {
    emit(AuthLoading());

    try {
      final deviceId = await DeviceUtils.getDeviceId();

      // Try to get existing user
      UserEntity? user = await _userRepository.getUserByDeviceId(deviceId);

      // If no user exists, create a new one
      user ??= await _userRepository.createUser(deviceId);

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Failed to initialize user'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
