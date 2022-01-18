import 'package:meta/meta.dart';

@immutable
class Constants {

  const Constants._();

  static const commandGenerate = "generate";
  static const commandBuild = "build";

  static const fileTypeJson = "json";
  static const fileTypeEnv = "env";

  static const buildVariantRelease = "release";
  static const buildVariantDebug = "debug";
  static const buildVariantProfile = "profile";

  static const processFlutter = "flutter";
  static const processBuild = "build";
  static const processClean = "clean";

  static const availableCommands = [
    commandGenerate,
    commandBuild,
  ];

  static const supportedBuildPlatforms = [
    "aar",
    "apk",
    "appbundle",
    "bundle",
    "ios",
    "ios-framework",
    "ipa",
    "web",
  ];
}

enum CommandType {
  generate,
  build,
}

enum GenerateFileType {
  json,
  env,
}

enum BuildVariant {
  release,
  debug,
  profile,
}