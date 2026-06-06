class AiDiagnosis {
  final String? predictedLabel;
  final double? confidence;
  final Map<String, double> allProbabilities;

  AiDiagnosis({
    required this.predictedLabel,
    required this.confidence,
    required this.allProbabilities,
  });

  Map<String, dynamic> toMap() => {
    'predictedLabel': predictedLabel,
    'confidence': confidence,
    'allProbabilities': allProbabilities,
  };

  factory AiDiagnosis.fromMap(Map<String, dynamic> map) {
    final rawProbs = map['allProbabilities'] as Map<String, dynamic>? ?? {};
    final allProbabilities = rawProbs.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return AiDiagnosis(
      predictedLabel: map['predictedLabel'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble(),
      allProbabilities: allProbabilities,
    );
  }
}
