import 'package:diagnose_app/data/repositories/auth_repository.dart';
import 'package:diagnose_app/data/sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<String?> login(String email, String password) =>
      _remote.login(email, password);

  @override
  Future<void> register(
    String email,
    String password,
    String name,
    DateTime birthDate,
    String gender,
  ) => _remote.register(
    email: email,
    password: password,
    name: name,
    birthDate: birthDate,
    gender: gender,
  );
}
