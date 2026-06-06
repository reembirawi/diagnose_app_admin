class AppStrings {
  AppStrings._();

  // UI
  static const String welcomeBack = 'Welcome back!';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Log in';
  static const String invalidEmail = 'Enter a valid email';
  static const String shortPassword = 'Password must be at least 6 characters';
  static const String accessDenied = 'Access denied. Admins only.';
  static const String loginFailed = 'Login failed';

  // Firestore collections
  static const String usersCollection = 'users';

  // Firestore fields
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String birthDateField = 'birthDate';
  static const String genderField = 'gender';
  static const String skinTypeField = 'skinType';
  static const String sunExposureField = 'sunExposure';
  static const String smokingStatusField = 'smokingStatus';
  static const String isCompleteField = 'isComplete';
  static const String roleField = 'role';
  static const String defaultRole = 'user';

  // Admin Dashboard
  static const String appName = 'Dermalayzer';
  static const String navDashboard = 'Dashboard';
  static const String navDoctors = 'Doctors';
  static const String navUsers = 'Users';

  // Home Dashboard
  static const String dashboardOverview = 'Dashboard Overview';
  static const String scansThisMonth = 'Scans This Month';
  static const String doctors = 'Doctors';
  static const String users = 'Users';
  static const String pendingApprovals = 'Pending Approvals';
  static const String aiDiagnosisBreakdown = 'AI Diagnosis Breakdown';
  static const String benign = 'Benign';
  static const String malignant = 'Malignant';
  static const String notDiagnosedYet = 'Not diagnosed yet';
  static const String doctorsPendingApproval = 'Doctors Pending Approval';
  static const String recentUsers = 'Recent Users';
  static const String waiting = 'waiting';
  static const String scans = 'scans';
  static const String unknown = 'Unknown';
  static const String reportsCollection = 'reports';
  static const String doctorRole = 'doctor';
  static const String userRole = 'user';
  static const String statusField = 'status';
  static const String approvedStatus = 'approved';
  static const String pendingStatus = 'pending';
  static const String userIdField = 'userId';

  // Doctors Dashboard
  static const String doctorsDashboard = 'Doctors Dashboard';
  static const String doctorsSubtitle =
      'Manage all registered doctors and approvals';
  static const String totalDoctors = 'Total Doctors';
  static const String approvedDoctors = 'Approved Doctors';
  static const String suspendedDoctors = 'Suspended Doctors';
  static const String searchDoctors = 'Search doctors...';
  static const String noDoctorsFound = 'No doctors found.';
  static const String viewProfile = 'View profile';
  static const String approve = 'Approve';
  static const String suspend = 'Suspend';
  static const String reinstate = 'Reinstate';
  static const String active = 'Active';
  static const String pending = 'Pending';
  static const String suspended = 'Suspended';
  static const String yearsExp = 'Years exp.';
  static const String scansDone = 'Scans done';
  static const String doneRatio = 'Done ratio';
  static const String appliedPrefix = 'Applied ';
  static const String licenseVerified = 'License verified';
  static const String noCertificate = 'No certificate uploaded';
  static const String failedCertificate = 'Failed to load certificate';
  static const String justNow = 'Just now';
  static const String noName = 'No Name';
  static const String noEmail = 'No Email';
  static const String noGender = 'No Gender';
  static const String sortNameAZ = 'Name A–Z';
  static const String sortNameZA = 'Name Z–A';
  static const String sortRatingHL = 'Rating High–Low';
  static const String sortRatingLH = 'Rating Low–High';
  static const String suspendedStatus = 'suspended';
  static const String approvedStatus2 = 'approved';
  static const String gender = 'Gender';
  static const String dateOfBirth = 'Date of Birth';
  static const String yearsOfExperience = 'Years of Experience';
  static const String description = 'Description';

  // Firestore fields - doctors
  static const String secondNameField = 'secondName';
  static const String locationField = 'location';
  static const String statusField2 = 'status';
  static const String yearsOfExperienceField = 'yearsOfExperience';
  static const String createdAtField = 'created_at';
  static const String licenseVerifiedField = 'license_verified';
  static const String certificateUrlField = 'certificateUrl';
  static const String descriptionField = 'description';
  static const String scansDoneField = 'scans_done';
  static const String scansRemainingField = 'scans_remaining';
  static const String birthDateField2 = 'birthDate';

  // Users Dashboard
  static const String usersDashboard = 'Users Dashboard';
  static const String usersSubtitle =
      'Manage all registered users and their scans';
  static const String searchUsers = 'Search users...';
  static const String noUsersFound = 'No users found.';
  static const String totalUsers = 'Total Users';
  static const String totalScans = 'Total Scans';
  static const String diagnosedScans = 'Diagnosed Scans';
  static const String totalScansLabel = 'Total Scans';
  static const String doneScansLabel = 'Done Scans';
  static const String pendingScansLabel = 'Pending Scans';
  static const String noDoctor = 'No doctor selected';
  static const String doctorPrefix = 'Dr. ';
  static const String submitField = 'submit';
  static const String doctorField = 'doctor';
}
