import 'package:cloud_firestore/cloud_firestore.dart';

/// Holds the computed diagnosis distribution across all reports.
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

/// Streams real-time [DiagnosisStats] derived from the `reports` collection.
///
/// Firestore schema used:
/// ```
/// reports/{id}
///   aiDiagnosis (map)
///     allProbabilities (map)
///       benign   : double   e.g. 1.0
///       malignant: double   e.g. 3.9e-10
///     confidence : null | double
///     predictedLabel: null | string
/// ```
///
/// Logic:
///   • Compare benign vs malignant probability values.
///   • Whichever is higher wins — that report is counted in that bucket.
///   • If `aiDiagnosis` or `allProbabilities` is absent/null, or both
///     probabilities are 0, the report goes into "Not diagnosed yet".
Stream<DiagnosisStats> diagnosisStatsStream() {
  return FirebaseFirestore.instance.collection('reports').snapshots().map((
    snapshot,
  ) {
    int benign = 0;
    int malignant = 0;
    int notDiagnosed = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Navigate: aiDiagnosis → allProbabilities
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

      // The class with the larger probability is the diagnosis.
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
