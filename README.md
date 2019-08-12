Xamarin.Essentials VersionTacking for Flutter

## Introduction

This is pretty much as copy/paste job from the Xamarin folks with a few adjustments to make things work for Flutter. 

## Documentation

[docs.microsoft.com/xamarin/essentials/version-tracking](https://docs.microsoft.com/en-us/xamarin/essentials/version-tracking)

## Usage

The Xamarin.Essentials VersionTracking requires calling `Track()` each time the application runs, in the Flutter version, calling the constructor `from` accomplishes the same thing.

```dart
void main() {
    SharedPreferences.getInstance().then((sharedPreferences) {
        PackageInfo.fromPlatform().then((packageInfo) {
            runApp(MyApp(
                versionTracking: VersionTracking.from(
                    sharedPreferences: sharedPreferences,
                    packageInfo: packageInfo
                )
            ));
        });
    });
}

class MyApp extends StatelessWidget {
    MyApp({this.versionTrackings});

    final VersionTracking versionTracking;
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/jamiewest/version_tracking/issues
