// ignore_for_file: avoid_print
library flutter_dd_cli;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dd_cli/src/constants.dart';
import 'package:flutter_dd_cli/src/errors.dart';

class FlutterDDCLI {

  FlutterDDCLI(List<String> arguments,): _arguments = arguments.toSet();

  final Set<String> _arguments;

  CommandType _getCommandType(String? arg,) {
    switch (arg) {
      case Constants.commandBuild:
        return CommandType.build;
      case Constants.commandGenerate:
        return CommandType.generate;
    }
    throw UnknownCommandError(arg,);
  }

  void _printHelp(CommandType type,) {
    print(type,);
    // switch (type) {
    //   case CommandType.generate:
    //
    //     break;
    //   case CommandType.build:
    //     break;
    // }
  }

  GenerateFileType _getFileType(String? arg,) {
    switch (arg) {
      case Constants.fileTypeJson:
        return GenerateFileType.json;
      case Constants.fileTypeEnv:
        return GenerateFileType.env;
    }
    throw FallThroughError();
  }

  BuildVariant? _getBuildVariant(String? arg,) {
    switch (arg?.replaceAll("-", "",)) {
      case Constants.buildVariantRelease:
        return BuildVariant.release;
      case Constants.buildVariantProfile:
        return BuildVariant.profile;
      case Constants.buildVariantDebug:
        return BuildVariant.debug;
    }
  }

  File _getFileFromPath(String? arg,) {
    if (arg != null) {
      final file = File(arg,);
      if (file.existsSync()) {
        return file;
      }
    }
    throw FileNotFoundError(arg,);
  }

  String? _findElementAt(int index,) {
    if (index < _arguments.length) {
      return _arguments.elementAt(index,);
    }
  }

  Future<String> _generateDartDefines(GenerateFileType fileType, File file,) async {
    switch (fileType) {
      case GenerateFileType.json:
        final fileContent = await file.readAsString();
        final Map<String, dynamic> jsonObject = await jsonDecode(fileContent,);
        final spaceRegex = RegExp(r"\s",);
        return jsonObject.entries.where(
          (entry,) {
            final value = entry.value;
            if (value is String) {
              return !spaceRegex.hasMatch(value,);
            } else {
              return [
                int,
                double,
                bool,
              ].contains(value.runtimeType,);
            }
          },
        ).map(
          (entry,) {
            return "--dart-define=${entry.key}=${entry.value}";
          },
        ).join(" ",);
      case GenerateFileType.env:
        final regex = RegExp(r"^[\w\d_]+=\S+$",);
        return file.openRead().transform(
          utf8.decoder,
        ).transform(
          const LineSplitter(),
        ).where(
          (line) => regex.hasMatch(line,),
        ).map(
          (line) => "--dart-define=$line",
        ).join(" ",);
    }
  }

  final Map<BuildVariant, String> _buildVariantStrings = {
    BuildVariant.release: "--release",
    BuildVariant.profile: "--profile",
    BuildVariant.debug: "--debug",
  };

  Future<void> _performBuild(String platform, BuildVariant variant, {
    bool clean = false,
  }) async {
    Process? process;
    if (clean) {
      process = await Process.start(
        Constants.processFlutter,
        [
          Constants.processClean,
        ],
      );
      // stdout.write(process.stdout,);
      // stderr.write(process.stderr,);
      process.stdout.transform(utf8.decoder,).forEach(print,);
      process.stderr.transform(utf8.decoder,).forEach(print,);
      await process.exitCode;
    }
    process = await Process.start(
      Constants.processFlutter,
      [
        Constants.processBuild,
        platform,
        _buildVariantStrings[variant]!,
      ],
    );
    // stdout.write(process.stdout,);
    // stderr.write(process.stderr,);
    process.stdout.transform(utf8.decoder,).forEach(print,);
    process.stderr.transform(utf8.decoder,).forEach(print,);
    await process.exitCode;
  }

  Future<void> run() async {
    if (_arguments.length < 2) {
      throw ArgumentError("Not enough arguments",);
    }
    final _type = _arguments.first;
    final type = _getCommandType(_type,);
    final objArg = _arguments.elementAt(1,);
    final isHelp = [
      "--help",
      "-h",
    ].contains(objArg,);

    if (isHelp) {
      _printHelp(type,);
      return;
    }

    final String? _fileType = _findElementAt(1,);
    final GenerateFileType fileType = _getFileType(_fileType,);
    final String? filePath = _findElementAt(2,);
    final File file = _getFileFromPath(filePath,);
    final dartDefines = await _generateDartDefines(fileType, file,);
    if (type == CommandType.generate) {
      print(
        dartDefines,
      );
    } else if (type == CommandType.build) {
      final String? _platform = _findElementAt(3,);
      if (_platform == null || !Constants.supportedBuildPlatforms.contains(_platform,)) {
        throw UnsupportedError(
          "Unsupported Platform. Supported Platforms are ${Constants.supportedBuildPlatforms.join(", ",)}",
        );
      }
      String? arg = _findElementAt(4,);
      late final BuildVariant variant;
      bool clean = false;
      if (arg != null) {
        variant = _getBuildVariant(arg,) ?? BuildVariant.release;
        const cleanArg = "--clean";
        if (arg == cleanArg) {
          clean = true;
        }
        arg = _findElementAt(5,);
        if (arg == cleanArg) {
          clean = true;
        }
      } else {
        variant = BuildVariant.release;
      }
      await _performBuild(_platform, variant, clean: clean,);
    }
  }

}