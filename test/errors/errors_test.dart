import 'package:apliarte_flutter_connect/apliarte_flutter_connect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConnectException keeps typed error code', () {
    const error = ConnectException(
      ConnectErrorCode.protocolMismatch,
      'Wrong protocol version.',
    );

    expect(error.code, ConnectErrorCode.protocolMismatch);
    expect(error.toString(), contains('protocolMismatch'));
    expect(error.toString(), contains('Wrong protocol version.'));
  });
}
