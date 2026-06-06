import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/models/report.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> usersStream() => _db
      .collection(AppStrings.usersCollection)
      .where(AppStrings.roleField, isEqualTo: AppStrings.userRole)
      .snapshots();

  Stream<QuerySnapshot> totalScansStream() =>
      _db.collection(AppStrings.reportsCollection).snapshots();

  Stream<QuerySnapshot> diagnosedScansStream() => _db
      .collection(AppStrings.reportsCollection)
      .where(AppStrings.submitField, isEqualTo: true)
      .snapshots();

  Future<List<Report>> fetchReports() async {
    final snapshot = await _db.collection(AppStrings.reportsCollection).get();
    return snapshot.docs
        .map((doc) => Report.fromMap(doc.id, doc.data()))
        .toList();
  }

  int calculateAge(dynamic birthDate) {
    if (birthDate == null || birthDate is! Timestamp) return 0;
    final dob = birthDate.toDate();
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day))
      age--;
    return age;
  }
}
