
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

const String _versionsKey = "VersionTracking.Versions";
const String _buildsKey = "VersionTracking.Builds";

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
    @required SharedPreferences preferences, 
    @required PackageInfo info}) {
    
    Map<String, List<String>> versionTrail = Map<String, List<String>>();;

    var isFirstLaunchEver = !preferences.containsKey(_versionsKey) || !preferences.containsKey(_buildsKey);
    if (isFirstLaunchEver) {
      
      versionTrail.addAll({
        _versionsKey: List<String>(), 
        _buildsKey: List<String>()} );

    } else {
      versionTrail.addAll({
        _versionsKey: _readHistory(preferences, _versionsKey).toList(),
        _buildsKey: _readHistory(preferences, _buildsKey).toList()
      });
    }

    var currentVersion = info.version;
    var currentBuild = info.buildNumber;

    var isFirstLaunchForCurrentVersion = !versionTrail[_versionsKey].contains(currentVersion);    
    if (isFirstLaunchForCurrentVersion) {
      versionTrail[_versionsKey].add(currentVersion);
    }

    var isFirstLaunchForCurrentBuild = !versionTrail[_buildsKey].contains(currentBuild);
    if (isFirstLaunchForCurrentBuild) {
        versionTrail[_buildsKey].add(currentBuild);
    }

    if (isFirstLaunchForCurrentVersion || isFirstLaunchForCurrentBuild) {
        _writeHistory(preferences, _versionsKey, versionTrail[_versionsKey]);
        _writeHistory(preferences, _buildsKey, versionTrail[_buildsKey]);
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

  /// First time ever launched application
  final bool isFirstLaunchEver;

  /// First time launching current version
  final bool isFirstLaunchForCurrentVersion;

  /// First time launching current build
  final bool isFirstLaunchForCurrentBuild;

  /// Current app version (2.0.0)
  final String currentVersion;

  /// Current build (2)
  final String currentBuild;

  /// Previous app version (1.0.0)
  final String previousVersion;

  /// Previous app build (1)
  final String previousBuild;

  /// First version of app installed (1.0.0)
  final String firstInstalledVersion;

  /// First build of app installed (1)
  final String firstInstalledBuild;

  /// List of versions installed (1.0.0, 2.0.0)
  final List<String> versionHistory;

  /// List of builds installed (1, 2)
  final List<String> buildHistory;

  bool isFirstLaunchForVersion(String version) =>
    currentVersion == version && isFirstLaunchForCurrentVersion;

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