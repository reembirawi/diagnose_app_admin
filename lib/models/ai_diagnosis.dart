class AiDiagnosis {
  final String disease;
  final double confidence;

  AiDiagnosis({
    required this.disease,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
        'disease': disease,
        'confidence': confidence,
      };

  factory AiDiagnosis.fromMap(Map<String, dynamic> map) {
    return AiDiagnosis(
      disease: map['disease'],
      confidence: map['confidence'],
    );
  }
}