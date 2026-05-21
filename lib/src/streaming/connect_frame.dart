import 'dart:convert';
import 'dart:typed_data';

import '../config/connect_config.dart';
import '../errors/connect_exception.dart';

/// Supported frame payload formats.
enum FrameFormat { jpeg, png, webp, binary, json }

/// Metadata attached to a frame payload.
final class FrameMetadata {
  factory FrameMetadata({
    required int sequenceNumber,
    DateTime? timestamp,
    int? width,
    int? height,
    String? contentType,
  }) {
    if (sequenceNumber < 0) {
      throw const ConnectException(
        ConnectErrorCode.invalidFrame,
        'sequenceNumber must not be negative.',
      );
    }
    if ((width != null && width < 1) || (height != null && height < 1)) {
      throw const ConnectException(
        ConnectErrorCode.invalidFrame,
        'width and height must be positive when provided.',
      );
    }
    return FrameMetadata._(
      sequenceNumber: sequenceNumber,
      timestamp: timestamp ?? DateTime.now().toUtc(),
      width: width,
      height: height,
      contentType: contentType,
    );
  }

  const FrameMetadata._({
    required this.sequenceNumber,
    required this.timestamp,
    required this.width,
    required this.height,
    required this.contentType,
  });

  final int sequenceNumber;
  final DateTime timestamp;
  final int? width;
  final int? height;
  final String? contentType;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sequenceNumber': sequenceNumber,
      'timestamp': timestamp.toIso8601String(),
      'width': width,
      'height': height,
      'contentType': contentType,
    };
  }
}

/// Binary or structured frame sent through a connection session.
final class ConnectFrame {
  factory ConnectFrame({
    required Uint8List bytes,
    required FrameFormat format,
    required FrameMetadata metadata,
    int maxBytes = ConnectConfig.defaultMaxFrameBytes,
  }) {
    _validate(bytes: bytes, format: format, maxBytes: maxBytes);
    return ConnectFrame._(bytes: bytes, format: format, metadata: metadata);
  }

  factory ConnectFrame.binary({
    required Uint8List bytes,
    required int sequenceNumber,
    int maxBytes = ConnectConfig.defaultMaxFrameBytes,
  }) {
    return ConnectFrame(
      bytes: bytes,
      format: FrameFormat.binary,
      metadata: FrameMetadata(sequenceNumber: sequenceNumber),
      maxBytes: maxBytes,
    );
  }

  factory ConnectFrame.image({
    required Uint8List bytes,
    required FrameFormat format,
    required int sequenceNumber,
    int? width,
    int? height,
    int maxBytes = ConnectConfig.defaultMaxFrameBytes,
  }) {
    if (format != FrameFormat.jpeg &&
        format != FrameFormat.png &&
        format != FrameFormat.webp) {
      throw const ConnectException(
        ConnectErrorCode.invalidFrame,
        'Image frames must use jpeg, png, or webp format.',
      );
    }
    return ConnectFrame(
      bytes: bytes,
      format: format,
      metadata: FrameMetadata(
        sequenceNumber: sequenceNumber,
        width: width,
        height: height,
        contentType: 'image/${format.name}',
      ),
      maxBytes: maxBytes,
    );
  }

  factory ConnectFrame.json({
    required Object? value,
    required int sequenceNumber,
    int maxBytes = ConnectConfig.defaultMaxFrameBytes,
  }) {
    final encoded = Uint8List.fromList(utf8.encode(jsonEncode(value)));
    return ConnectFrame(
      bytes: encoded,
      format: FrameFormat.json,
      metadata: FrameMetadata(
        sequenceNumber: sequenceNumber,
        contentType: 'application/json',
      ),
      maxBytes: maxBytes,
    );
  }

  const ConnectFrame._({
    required this.bytes,
    required this.format,
    required this.metadata,
  });

  final Uint8List bytes;
  final FrameFormat format;
  final FrameMetadata metadata;

  int get sizeBytes => bytes.lengthInBytes;

  static void _validate({
    required Uint8List bytes,
    required FrameFormat format,
    required int maxBytes,
  }) {
    if (bytes.isEmpty) {
      throw const ConnectException(
        ConnectErrorCode.invalidFrame,
        'Frame bytes must not be empty.',
      );
    }
    if (maxBytes < 1) {
      throw const ConnectException(
        ConnectErrorCode.invalidFrame,
        'maxBytes must be positive.',
      );
    }
    if (bytes.lengthInBytes > maxBytes) {
      throw ConnectException(
        ConnectErrorCode.frameTooLarge,
        'Frame has ${bytes.lengthInBytes} bytes, max allowed is $maxBytes.',
      );
    }
    if (format == FrameFormat.json) {
      try {
        jsonDecode(utf8.decode(bytes));
      } on FormatException catch (error) {
        throw ConnectException(
          ConnectErrorCode.invalidFrame,
          'JSON frames must contain valid UTF-8 JSON.',
          cause: error,
        );
      }
    }
  }
}
