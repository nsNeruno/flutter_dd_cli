# flutter_dd_cli [![Pub](https://img.shields.io/pub/v/flutter_dd_cli.svg)](https://pub.dartlang.org/packages/flutter_dd_cli)
A helper CLI Utility to simplify usages of Dart Defines.

## Features

- Generates a string of formatted `--dart-define`s ready to be pasted into any `flutter build` and `flutter run` commands.
- Simplify `flutter build` command by specifying an existing file containing ready-to-inject values (in json or line separated), converting them to `--dart-define` format.
- Provides an alternative way instead of editing `.vscode/launch.json` or `.idea/workspace.xml` directly.

## Getting started

### Installation
```sh
flutter pub global activate flutter_dd_cli
```
If you have direct access to pub in your ```PATH``` then you can omit the flutter prefix.

The CLI will be available as the terminal command ```fdd```. But in order to use it everywhere, e.g on your current Flutter project directory, you have to add the [system cache](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path) bin directory to your **PATH** environment variable.

Assuming the Flutter installation is located at the default location, here are some known possible ```PATH```s:
- #### MacOS/Linux Path:
```sh
$HOME/.pub-cache/bin
```
- #### Windows Path:
```console
%LOCALAPPDATA%\Pub\Cache\bin
```

## Usage

### Generate Dart Defines
#### From JSON File
Given the sample JSON File below with name ```env.json```
```json
{
    "log": true,
    "apiKeyA": "NeverGonnaGiveYouUp",
    "apiKeyB": "NeverGonnaLetYouDown",
    "apiKeyC": "NeverGonnaRunAround",
    "protocol": "and",
    "baseUrl": "Deserts.You",
    "port": 420
}
```
Assuming ```env.json``` is currently located at current working directory
```sh
fdd generate json env.json

# or if the file is located somewhere else
fdd generate json /path/to/env.json
```
#### From Formatted Env File
For this method, the `env` file is expected to be in this format, read line by line:
```
log=true
apiKeyA=NeverGonnaGiveYouUp
apiKeyB=NeverGonnaLetYouDown
apiKeyC=NeverGonnaRunAround
protocol=and
baseUrl=Deserts.You
port=420
```
Where `key` consists of alphanumeric and underscores and `value` consists of String-likes.
```sh
# assuming the file name is config
fdd generate env config

# or named debug.old
fdd generate env debug.old

# from somewhere else
fdd generate env /path/to/env
```
### Generated Result
The result is expected to look like this
```
--dart-define=log=true --dart-define=apiKeyA=NeverGonnaGiveYouUp ...
```
You may copy/pipe the result from your terminal and use it directly on your `flutter build`/`flutter run` script or add it into Run/Build Configuration section on **Android Studio**.

### Build with Dart Defines
The `build` command will delegate the arguments into `flutter build` command.
```sh
# This will delegate the dart defines into flutter build appbundle --release command
fdd build json env.json appbundle --release

# Delegates to flutter build apk --debug
fdd build env debug.old apk --debug

# Add --clean to run flutter clean before flutter build
fdd build json env.json appbundle --release --clean

# Clean and defaults to --release
fdd build json env.json appbundle --clean
```
#### Outputs
The generated build files are located at the same location defined by `flutter build` command.

Extra: it also pipes the `stdout` and `stderr` from the `flutter` commands.

## Additional information

### Constraints
- Values with spaces are not allowed
- Invalid entries are skipped
- For referencing an `env` file, avoid naming the file as `env`

## TODOs
- Integrate **flutter run**
- Add contents for **--help** / **-h** arguments
- Add more textual Error Messages
- Add more Error classes
- Code breakdown into smaller classes
- Localizations