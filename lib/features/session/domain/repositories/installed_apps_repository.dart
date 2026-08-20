class InstalledApp {
  const InstalledApp({required this.packageName, required this.label});

  final String packageName;
  final String label;
}

abstract class InstalledAppsRepository {
  /// Launchable apps only (MAIN/LAUNCHER). Empty on non-Android.
  Future<List<InstalledApp>> listLaunchable();
}
