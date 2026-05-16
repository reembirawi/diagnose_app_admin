class DoctorDiagnosis {
  final String diagnosis;
  final String notes;

  DoctorDiagnosis({required this.diagnosis, required this.notes});

  Map<String, dynamic> toMap() => {'diagnosis': diagnosis, 'notes': notes};

  factory DoctorDiagnosis.fromMap(Map<String, dynamic> map) {
    return DoctorDiagnosis(
      diagnosis: map['diagnosis'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}
