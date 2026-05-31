import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosisStats {
  final int benign;
  final int malignant;
  final int notDiagnosed;
  final int total;

  const DiagnosisStats({
    required this.benign,
    required this.malignant,
    required this.notDiagnosed,
    required this.total,
  });

  double get benignRatio => total == 0 ? 0 : benign / total;
  double get malignantRatio => total == 0 ? 0 : malignant / total;
  double get notDiagnosedRatio => total == 0 ? 0 : notDiagnosed / total;
}

Stream<DiagnosisStats> diagnosisStatsStream() {
  return FirebaseFirestore.instance.collection('reports').snapshots().map((
    snapshot,
  ) {
    int benign = 0;
    int malignant = 0;
    int notDiagnosed = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final aiDiagnosis = data['aiDiagnosis'];
      if (aiDiagnosis == null || aiDiagnosis is! Map) {
        notDiagnosed++;
        continue;
      }

      final allProbs = aiDiagnosis['allProbabilities'];
      if (allProbs == null || allProbs is! Map) {
        notDiagnosed++;
        continue;
      }

      final double benignProb = (allProbs['benign'] as num?)?.toDouble() ?? 0.0;
      final double malignantProb =
          (allProbs['malignant'] as num?)?.toDouble() ?? 0.0;

      if (benignProb == 0.0 && malignantProb == 0.0) {
        notDiagnosed++;
        continue;
      }
      if (benignProb >= malignantProb) {
        benign++;
      } else {
        malignant++;
      }
    }

    final total = benign + malignant + notDiagnosed;
    return DiagnosisStats(
      benign: benign,
      malignant: malignant,
      notDiagnosed: notDiagnosed,
      total: total,
    );
  });
}
