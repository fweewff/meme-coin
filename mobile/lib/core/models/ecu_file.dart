import 'dart:typed_data';

class EcuFile {
  const EcuFile({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.rawBytes,
  });

  final String id;
  final String fileName;
  final DateTime createdAt;
  final Uint8List rawBytes;

  // TODO: Implement serialization and storage metadata mapping.
}
