import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diagnose_app/core/constants/app_colors.dart';
import 'package:diagnose_app/core/constants/app_strings.dart';

class DoctorProfileDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const DoctorProfileDialog({super.key, required this.data});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final name = data[AppStrings.nameField] ?? AppStrings.noName;
    final secondName = data[AppStrings.secondNameField] ?? '';
    final email = data[AppStrings.emailField] ?? AppStrings.noEmail;
    final gender = data[AppStrings.genderField] ?? AppStrings.noGender;
    final birthDate = (data[AppStrings.birthDateField2] as Timestamp?)
        ?.toDate();
    final yearsExp = data[AppStrings.yearsOfExperienceField] ?? 0;
    final desc = data[AppStrings.descriptionField] ?? '';
    final certificateUrl = data[AppStrings.certificateUrlField];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF7B7FC4)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '$name $secondName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                const Divider(),
                _InfoSection(
                  rows: [
                    _InfoRow(Icons.wc, AppStrings.gender, gender),
                    _InfoRow(
                      Icons.cake,
                      AppStrings.dateOfBirth,
                      _formatDate(birthDate),
                    ),
                    _InfoRow(
                      Icons.medical_services,
                      AppStrings.yearsOfExperience,
                      '$yearsExp',
                    ),
                    _InfoRow(Icons.description, AppStrings.description, desc),
                  ],
                ),
                const SizedBox(height: 18),
                _CertificateSection(url: certificateUrl),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows
            .map(
              (r) => Column(
                children: [
                  r,
                  const Divider(height: 1, color: Color(0xFFF0F0F8)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoRow(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF7B7FC4)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class _CertificateSection extends StatelessWidget {
  final dynamic url;
  const _CertificateSection({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url.toString().isEmpty) {
      return const Text(AppStrings.noCertificate);
    }
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) =>
            Dialog(child: InteractiveViewer(child: Image.network(url))),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          height: 200,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
          errorBuilder: (_, __, ___) =>
              const Text(AppStrings.failedCertificate),
        ),
      ),
    );
  }
}
