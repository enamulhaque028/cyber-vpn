abstract class TunnelRepository {
  Future<void> initialize({
    required void Function(String stage) onStage,
    required void Function(String duration, String byteIn, String byteOut)
    onStatus,
  });

  Future<void> connect({
    required String config,
    required String country,
    required String username,
    required String password,
  });

  Future<void> disconnect();
}
