/// Sunucunun bir video için aldığı parçalar.
class ReceivedChunksDTO {
  const ReceivedChunksDTO({this.receivedChunks});
  final List<int>? receivedChunks;

  factory ReceivedChunksDTO.fromJson(Map<String, dynamic> json) =>
      ReceivedChunksDTO(receivedChunks: (json['receivedChunks'] as List?)?.cast<int>());

  Map<String, dynamic> toJson() => {'receivedChunks': receivedChunks};
}

/// Video tamamlama isteği — sunucu parçaları birleştirip hash'i doğrular.
class CompleteVideoRequestDTO {
  const CompleteVideoRequestDTO({this.totalChunks, this.sha256});
  final int? totalChunks;
  final String? sha256;

  factory CompleteVideoRequestDTO.fromJson(Map<String, dynamic> json) =>
      CompleteVideoRequestDTO(totalChunks: json['totalChunks'] as int?, sha256: json['sha256'] as String?);

  Map<String, dynamic> toJson() => {'totalChunks': totalChunks, 'sha256': sha256};
}
