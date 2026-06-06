import 'package:intl/intl.dart';

// class Report {
//   String _title;
//   String _description;
//   final DateTime _date = DateTime.now();

//   Report(this._title, this._description);

//   // GETTER: Allows you to read the value
//   String get title => _title;

//   // SETTER: Allows you to update the value with logic
//   set title(String value) {
//     if (value.isNotEmpty) {
//       _title = value;
//     }
//   }

//   // Getter for description
//   String get description => _description;

//   String get formattedDate => DateFormat('dd-MM-yyyy').format(_date);

//   // Setter for description
//   set description(String value) => _description = value;
// }

import 'scan_request.dart';
import 'ai_diagnosis.dart';
import 'doctor_review.dart';

class Report {
  final String id;
  final String userId;
  String title;
  String description;
  final String doctorId;

  final ScanRequest request;
  final AiDiagnosis? aiDiagnosis;
  final DoctorDiagnosis? doctorDiagnosis;

  bool submit = false;

  Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.request,
    required this.aiDiagnosis,
    required this.doctorDiagnosis,
    required this.doctorId,
    required this.submit,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'description': description,
    'request': request.toMap(),
    'aiDiagnosis': aiDiagnosis?.toMap(),
    'doctorDiagnosis': doctorDiagnosis?.toMap(),
    'doctorId': doctorId,
    'submit': submit,
  };

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    final ScanRequest request;
    if (map['request'] != null) {
      request = ScanRequest.fromMap(map['request'] as Map<String, dynamic>);
    } else {
      // legacy flat structure: imageUrl and createdAt were at root level
      final raw = map['createdAt'];
      final createdAt = raw == null
          ? DateTime.now()
          : raw is String
              ? DateTime.parse(raw)
              : raw.toDate();
      request = ScanRequest(imageUrl: map['imageUrl'] ?? '', createdAt: createdAt);
    }

    return Report(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      request: request,
      aiDiagnosis: map['aiDiagnosis'] != null
          ? AiDiagnosis.fromMap(map['aiDiagnosis'])
          : null,
      doctorDiagnosis: map['doctorDiagnosis'] != null
          ? DoctorDiagnosis.fromMap(map['doctorDiagnosis'])
          : null,
      doctorId: map['doctorId'] ?? '',
      submit: map['submit'] ?? false,
    );
  }
}
