class DownloaderService {
  /// <-- Singleton
  DownloaderService._();

  static final DownloaderService _instance = DownloaderService._();

  factory DownloaderService() => _instance;

  /// Singleton -->
  /// Must call before runApp
  Future<void> init() async {}
}
