import 'package:shared_preferences/shared_preferences.dart';

/// Losse app-instellingen (poort van de iOS `@AppStorage`-waarden uit
/// ProfileView), bewaard in [SharedPreferences] met dezelfde sleutels.
///
/// De reminder-instellingen leven in `ReminderService`; dit dekt de rest:
/// bot-coach-modus, lichaamsmetingen-grafiek en trainingscalorie-credit.
class AppSettings {
  AppSettings._();

  static const String kBluntCoachMode = 'wwBluntCoachMode';
  static const String kShowBodyMeasurementsChart = 'wwShowBodyMeasurementsChart';
  static const String kTrainingCalorieCreditPercent = 'wwTrainingCalorieCreditPercent';

  static const double defaultTrainingCreditPercent = 50;

  static Future<bool> bluntCoachMode() async =>
      (await SharedPreferences.getInstance()).getBool(kBluntCoachMode) ?? false;

  static Future<void> setBluntCoachMode(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(kBluntCoachMode, value);

  static Future<bool> showBodyMeasurementsChart() async =>
      (await SharedPreferences.getInstance()).getBool(kShowBodyMeasurementsChart) ?? false;

  static Future<void> setShowBodyMeasurementsChart(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(kShowBodyMeasurementsChart, value);

  /// Percentage van de geschatte trainingscalorieën dat terugvloeit naar het
  /// dagbudget (0–100, default 50).
  static Future<double> trainingCalorieCreditPercent() async =>
      (await SharedPreferences.getInstance()).getDouble(kTrainingCalorieCreditPercent) ?? defaultTrainingCreditPercent;

  static Future<void> setTrainingCalorieCreditPercent(double value) async =>
      (await SharedPreferences.getInstance()).setDouble(kTrainingCalorieCreditPercent, value);
}
