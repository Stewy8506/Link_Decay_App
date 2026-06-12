class ExtensionService {
  ExtensionService._internal();
  static final ExtensionService instance = ExtensionService._internal();

  /// Always returns false on native platforms
  bool get isExtension => false;

  /// Always returns null on native platforms
  Future<String?> getCurrentTabUrl() async => null;
}
