
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

const String _versionsKey = "VersionTracking.Versions";
const String _buildsKey = "VersionTracking.Builds";

/// Provides an easy way to track an app's version on a device.
class VersionTracking {

  const VersionTracking({
    this.isFirstLaunchEver,
    this.isFirstLaunchForCurrentVersion,
    this.isFirstLaunchForCurrentBuild, 
    this.currentVersion,
    this.currentBuild,
    this.previousVersion,
    this.previousBuild,
    this.firstInstalledVersion,
    this.firstInstalledBuild,
    this.versionHistory,
    this.buildHistory
  });

  factory VersionTracking.from({
    @required SharedPreferences sharedPreferences, 
    @required PackageInfo packageInfo}) {
    
    Map<String, List<String>> versionTrail = Map<String, List<String>>();;

    var isFirstLaunchEver = !sharedPreferences.containsKey(_versionsKey) || !sharedPreferences.containsKey(_buildsKey);
    if (isFirstLaunchEver) {
      
      versionTrail.addAll({
        _versionsKey: List<String>(), 
        _buildsKey: List<String>()} );

    } else {
      versionTrail.addAll({
        _versionsKey: _readHistory(sharedPreferences, _versionsKey).toList(),
        _buildsKey: _readHistory(sharedPreferences, _buildsKey).toList()
      });
    }

    var currentVersion = packageInfo.version;
    var currentBuild = packageInfo.buildNumber;

    var isFirstLaunchForCurrentVersion = !versionTrail[_versionsKey].contains(currentVersion);    
    if (isFirstLaunchForCurrentVersion) {
      versionTrail[_versionsKey].add(currentVersion);
    }

    var isFirstLaunchForCurrentBuild = !versionTrail[_buildsKey].contains(currentBuild);
    if (isFirstLaunchForCurrentBuild) {
        versionTrail[_buildsKey].add(currentBuild);
    }

    if (isFirstLaunchForCurrentVersion || isFirstLaunchForCurrentBuild) {
        _writeHistory(sharedPreferences, _versionsKey, versionTrail[_versionsKey]);
        _writeHistory(sharedPreferences, _buildsKey, versionTrail[_buildsKey]);
    }

    return VersionTracking(
      isFirstLaunchEver: isFirstLaunchEver,
      isFirstLaunchForCurrentVersion: isFirstLaunchForCurrentVersion,
      isFirstLaunchForCurrentBuild: isFirstLaunchForCurrentBuild,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      previousVersion: _getPrevious(versionTrail, _versionsKey),
      previousBuild: _getPrevious(versionTrail, _buildsKey),
      firstInstalledVersion: versionTrail[_versionsKey].first,
      firstInstalledBuild: versionTrail[_buildsKey].first,
      versionHistory: versionTrail[_versionsKey].toList(),
      buildHistory: versionTrail[_buildsKey].toList()
    );
  }

  /// Gets a value indicating whether this is the first time this app has ever been launched on this device.
  final bool isFirstLaunchEver;

  /// Gets a value indicating if this is the first launch of the app for the current version number.
  final bool isFirstLaunchForCurrentVersion;

  /// Gets a value indicating if this is the first launch of the app for the current build number.
  final bool isFirstLaunchForCurrentBuild;

  /// Gets the current version number of the app.
  final String currentVersion;

  /// Gets the current build of the app.
  final String currentBuild;

  /// Gets the version number for the previously run version.
  final String previousVersion;

  /// Gets the build number for the previously run version.
  final String previousBuild;

  /// Gets the version number of the first version of the app that was installed on this device.
  final String firstInstalledVersion;

  /// Gets the build number of first version of the app that was installed on this device.
  final String firstInstalledBuild;

  /// Gets the collection of version numbers of the app that ran on this device.
  final List<String> versionHistory;

  /// Gets the collection of build numbers of the app that ran on this device.
  final List<String> buildHistory;

  /// Determines if this is the first launch of the app for a specified version number.
  bool isFirstLaunchForVersion(String version) =>
    currentVersion == version && isFirstLaunchForCurrentVersion;

  /// Determines if this is the first launch of the app for a specified build number.
  bool isFirstLaunchForBuild(String build) =>
    currentBuild == build && isFirstLaunchForCurrentBuild;

  @override
  String toString() {
    var sb = StringBuffer();
    sb.writeln();
    sb.writeln('VersionTracking');
    sb.writeln('IsFirstLaunchEver:              ${isFirstLaunchEver}');
    sb.writeln('IsFirstLaunchForCurrentVersion: ${isFirstLaunchForCurrentVersion}');
    sb.writeln('IsFirstLaunchForCurrentBuild:   ${isFirstLaunchForCurrentBuild}');
    sb.writeln();
    sb.writeln('CurrentVersion:                 ${currentVersion}');
    sb.writeln('PreviousVersion:                ${previousVersion}');
    sb.writeln('FirstInstalledVersion:          ${firstInstalledVersion}');
    sb.writeln('VersionHistory:                 ${versionHistory.join(", ")}');
    sb.writeln();
    sb.writeln('CurrentBuild:                   ${currentBuild}');
    sb.writeln('PreviousBuild:                  ${previousBuild}');
    sb.writeln('FirstInstalledBuild:            ${firstInstalledBuild}');
    sb.writeln('BuildHistory:                   ${buildHistory.join(", ")}');
    return sb.toString();
  }

  static List<String> _readHistory(SharedPreferences preferences, String key) =>
    preferences.getString(key).split('|');

  static void _writeHistory(SharedPreferences preferences, String key, List<String> history) =>
    preferences.setString(key, history.join('|'));


  static String _getPrevious(Map<String, List<String>> versionTrail, String key) {
    var trail = versionTrail[key];
    return (trail.length >= 2) ? trail[trail.length - 2] : null;
  }
}