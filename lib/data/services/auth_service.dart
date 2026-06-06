import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diagnose_app/data/repositories/auth_repository_impl.dart';
import 'package:diagnose_app/data/sources/auth_remote_data_source.dart';

class AuthService {
  final AuthRepositoryImpl _repo = AuthRepositoryImpl(
    AuthRemoteDataSource(FirebaseAuth.instance, FirebaseFirestore.instance),
  );

  Future<String?> login(String email, String password) =>
      _repo.login(email, password);
}
