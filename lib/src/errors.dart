class UnknownCommandError extends Error {

  final String? command;

  UnknownCommandError(this.command,);

  @override
  String toString() => "Unknown command: '$command'";
}

class FileNotFoundError extends Error {

  FileNotFoundError(this.path,);

  final String? path;

  @override
  String toString() => "File not found at $path";
}