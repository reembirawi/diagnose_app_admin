import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.auth, this.firestore);

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    required String gender,
  }) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    await firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'birthDate': birthDate,
      'gender': gender,
      'skinType': null,
      'sunExposure': null,
      'smokingStatus': null,
      'isComplete': false,
      'role': 'user',
    });
  }
}

abstract class AuthRepository {
  Future<void> register(
    String email,
    String password,
    String name,
    DateTime birthDate,
    String gender,
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<void> register(
    String email,
    String password,
    String name,
    DateTime birthDate,
    String gender,
  ) {
    return remote.register(
      email: email,
      password: password,
      name: name,
      birthDate: birthDate,
      gender: gender,
    );
  }
}
