import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';

class AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource(this.auth, this.firestore);

  Future<String?> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final uid = auth.currentUser!.uid;
    final doc = await firestore
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .get();
    return doc[AppStrings.roleField] as String?;
  }

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
    await firestore
        .collection(AppStrings.usersCollection)
        .doc(cred.user!.uid)
        .set({
          AppStrings.emailField: email,
          AppStrings.nameField: name,
          AppStrings.birthDateField: birthDate,
          AppStrings.genderField: gender,
          AppStrings.skinTypeField: null,
          AppStrings.sunExposureField: null,
          AppStrings.smokingStatusField: null,
          AppStrings.isCompleteField: false,
          AppStrings.roleField: AppStrings.defaultRole,
        });
  }
}
