import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';
import 'package:diagnose_app/data/models/report.dart';

class DoctorService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> doctorsStream(String filter) {
    final base = _db
        .collection(AppStrings.usersCollection)
        .where(AppStrings.roleField, isEqualTo: AppStrings.doctorRole);

    switch (filter) {
      case 'Active':
        return base
            .where(AppStrings.statusField, isEqualTo: AppStrings.approvedStatus)
            .snapshots();
      case 'Pending':
        return base
            .where(AppStrings.statusField, isEqualTo: AppStrings.pendingStatus)
            .snapshots();
      case 'Suspended':
        return base
            .where(
              AppStrings.statusField,
              isEqualTo: AppStrings.suspendedStatus,
            )
            .snapshots();
      default:
        return base.snapshots();
    }
  }

  Future<List<Report>> fetchReports() async {
    final snapshot = await _db.collection(AppStrings.reportsCollection).get();
    return snapshot.docs
        .map((doc) => Report.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateStatus(String docId, String status) => _db
      .collection(AppStrings.usersCollection)
      .doc(docId)
      .update({AppStrings.statusField: status});
}
