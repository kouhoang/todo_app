import 'package:todo_app/model/entities/user_entity.dart';
import '../network/supabase_service.dart';

class UserRepository {
  Future<UserEntity?> createUser(String deviceId) async {
    return await SupabaseService.createUser(deviceId);
  }

  Future<UserEntity?> getUserByDeviceId(String deviceId) async {
    return await SupabaseService.getUserByDeviceId(deviceId);
  }
}
