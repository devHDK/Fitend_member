class CommonException implements Exception {
  final String message;

  CommonException({required this.message});
}

class UploadException extends CommonException {
  UploadException({required super.message});
}
