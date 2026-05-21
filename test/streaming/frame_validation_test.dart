import 'dart:typed_data';

import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectFrame validates empty payloads', () {
    expect(
      () => ConnectFrame.binary(bytes: Uint8List(0), sequenceNumber: 1),
      throwsA(
        isA<ConnectException>().having(
          (ConnectException error) => error.code,
          'code',
          ConnectErrorCode.invalidFrame,
        ),
      ),
    );
  });

  test('ConnectFrame validates max size', () {
    expect(
      () => ConnectFrame.binary(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        sequenceNumber: 1,
        maxBytes: 2,
      ),
      throwsA(
        isA<ConnectException>().having(
          (ConnectException error) => error.code,
          'code',
          ConnectErrorCode.frameTooLarge,
        ),
      ),
    );
  });

  test('ConnectFrame creates valid json frame', () {
    final frame = ConnectFrame.json(
      value: <String, Object>{'type': 'hello'},
      sequenceNumber: 7,
    );

    expect(frame.format, FrameFormat.json);
    expect(frame.metadata.sequenceNumber, 7);
    expect(frame.sizeBytes, greaterThan(0));
  });
}
