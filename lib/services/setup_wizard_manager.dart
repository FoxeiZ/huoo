import 'package:shared_preferences/shared_preferences.dart';

/// Setup wizard steps
enum SetupStep {
  welcome,
  signIn,
  permissions,
  folders,
  completed;

  int get stepIndex {
    switch (this) {
      case SetupStep.welcome:
        return 0;
      case SetupStep.signIn:
        return 1;
      case SetupStep.permissions:
        return 2;
      case SetupStep.folders:
        return 3;
      case SetupStep.completed:
        return 4;
    }
  }

  static SetupStep fromIndex(int index) {
    switch (index) {
      case 0:
        return SetupStep.welcome;
      case 1:
        return SetupStep.signIn;
      case 2:
        return SetupStep.permissions;
      case 3:
        return SetupStep.folders;
      case 4:
      default:
        return SetupStep.completed;
    }
  }

  String get displayName {
    switch (this) {
      case SetupStep.welcome:
        return 'Welcome';
      case SetupStep.signIn:
        return 'Sign In';
      case SetupStep.permissions:
        return 'Permissions';
      case SetupStep.folders:
        return 'Music Folders';
      case SetupStep.completed:
        return 'Complete';
    }
  }
}

/// Manages the app's first-time setup wizard progress and completion status.
///
/// The setup wizard consists of multiple steps:
/// 1. Welcome Screen - Introduction to the app
/// 2. Sign In Screen - User account setup (optional)
/// 3. Permissions Screen - Required app permissions
/// 4. Folder Selection Screen - Music folder setup
///
/// The app will only show the setup wizard on first launch or if the user
/// hasn't completed all required steps.
class SetupWizardManager {
  // SharedPreferences keys
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _setupCompletedKey = 'setup_completed';
  static const String _currentStepKey = 'setup_current_step';
  static const String _welcomeCompletedKey = 'welcome_completed';
  static const String _signInCompletedKey = 'sign_in_completed';
  static const String _permissionsCompletedKey = 'permissions_completed';
  static const String _foldersCompletedKey = 'folders_completed';
  static const String _setupCompletedDateKey = 'setup_completed_date';

  /// Check if this is the first time the app is being launched
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  /// Check if the setup wizard has been completed
  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_setupCompletedKey) ?? false;
  }

  /// Get the current setup step
  static Future<SetupStep> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    final stepIndex = prefs.getInt(_currentStepKey) ?? 0;
    return SetupStep.fromIndex(stepIndex);
  }

  /// Mark the app as no longer first launch
  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  /// Update the current setup step
  static Future<void> setCurrentStep(SetupStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStepKey, step.stepIndex);

    // Also mark first launch as complete when we start the wizard
    if (step != SetupStep.welcome) {
      await markFirstLaunchComplete();
    }
  }

  /// Mark a specific step as completed
  static Future<void> markStepCompleted(SetupStep step) async {
    final prefs = await SharedPreferences.getInstance();

    String key;
    switch (step) {
      case SetupStep.welcome:
        key = _welcomeCompletedKey;
        break;
      case SetupStep.signIn:
        key = _signInCompletedKey;
        break;
      case SetupStep.permissions:
        key = _permissionsCompletedKey;
        break;
      case SetupStep.folders:
        key = _foldersCompletedKey;
        break;
      case SetupStep.completed:
        return; // Handle this separately
    }

    await prefs.setBool(key, true);

    // Check if all steps are completed
    await _checkAndMarkSetupComplete();
  }

  /// Check if a specific step has been completed
  static Future<bool> isStepCompleted(SetupStep step) async {
    final prefs = await SharedPreferences.getInstance();

    String key;
    switch (step) {
      case SetupStep.welcome:
        key = _welcomeCompletedKey;
        break;
      case SetupStep.signIn:
        key = _signInCompletedKey;
        break;
      case SetupStep.permissions:
        key = _permissionsCompletedKey;
        break;
      case SetupStep.folders:
        key = _foldersCompletedKey;
        break;
      case SetupStep.completed:
        return await isSetupCompleted();
    }

    return prefs.getBool(key) ?? false;
  }

  /// Get the next step in the setup process
  static Future<SetupStep> getNextStep() async {
    // If setup is completed, return completed
    if (await isSetupCompleted()) {
      return SetupStep.completed;
    }

    // Find the next incomplete step
    for (int i = 0; i < SetupStep.values.length - 1; i++) {
      final step = SetupStep.fromIndex(i);
      if (!await isStepCompleted(step)) {
        return step;
      }
    }

    return SetupStep.completed;
  }

  /// Mark the entire setup as completed
  static Future<void> markSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupCompletedKey, true);
    await prefs.setString(
      _setupCompletedDateKey,
      DateTime.now().toIso8601String(),
    );
    await setCurrentStep(SetupStep.completed);
  }

  /// Reset the setup wizard (useful for testing or user requesting reset)
  static Future<void> resetSetup() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_setupCompletedKey),
      prefs.remove(_currentStepKey),
      prefs.remove(_welcomeCompletedKey),
      prefs.remove(_signInCompletedKey),
      prefs.remove(_permissionsCompletedKey),
      prefs.remove(_foldersCompletedKey),
      prefs.remove(_setupCompletedDateKey),
    ]);
  }

  /// Get setup completion progress (0.0 to 1.0)
  static Future<double> getSetupProgress() async {
    if (await isSetupCompleted()) {
      return 1.0;
    }

    int completedSteps = 0;
    const totalSteps = 4; // welcome, signIn, permissions, folders

    for (int i = 0; i < totalSteps; i++) {
      final step = SetupStep.fromIndex(i);
      if (await isStepCompleted(step)) {
        completedSteps++;
      }
    }

    return completedSteps / totalSteps;
  }

  /// Get when setup was completed (if completed)
  static Future<DateTime?> getSetupCompletedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_setupCompletedDateKey);

    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Internal method to check if all required steps are completed
  static Future<void> _checkAndMarkSetupComplete() async {
    // Check if all required steps are completed
    final welcomeCompleted = await isStepCompleted(SetupStep.welcome);
    final permissionsCompleted = await isStepCompleted(SetupStep.permissions);

    // Sign-in is optional, folders are optional (can be set up later)
    // But we require at least welcome and permissions
    if (welcomeCompleted && permissionsCompleted) {
      await markSetupCompleted();
    }
  }

  /// Skip the setup wizard (for users who want to set up later)
  static Future<void> skipSetup() async {
    await markStepCompleted(SetupStep.welcome);
    await markStepCompleted(SetupStep.permissions);
    await markSetupCompleted();
  }

  /// Check if the user should see the setup wizard
  static Future<bool> shouldShowSetupWizard() async {
    final isFirstTime = await isFirstLaunch();
    final isCompleted = await isSetupCompleted();

    return isFirstTime || !isCompleted;
  }

  /// Get a summary of the setup status for debugging
  static Future<Map<String, dynamic>> getSetupStatus() async {
    return {
      'isFirstLaunch': await isFirstLaunch(),
      'isSetupCompleted': await isSetupCompleted(),
      'currentStep': (await getCurrentStep()).displayName,
      'welcomeCompleted': await isStepCompleted(SetupStep.welcome),
      'signInCompleted': await isStepCompleted(SetupStep.signIn),
      'permissionsCompleted': await isStepCompleted(SetupStep.permissions),
      'foldersCompleted': await isStepCompleted(SetupStep.folders),
      'setupProgress': await getSetupProgress(),
      'setupCompletedDate': await getSetupCompletedDate(),
    };
  }
}
