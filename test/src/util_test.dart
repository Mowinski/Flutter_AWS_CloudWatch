import 'package:aws_cloudwatch/src/util.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

main() {
  group('Constants', () {
    test('GROUP_NAME_REGEX_PATTERN', () {
      expect(GROUP_NAME_REGEX_PATTERN, r'^[\.\-_/#A-Za-z0-9]+$');
    });
    test('STREAM_NAME_REGEX_PATTERN', () {
      expect(STREAM_NAME_REGEX_PATTERN, r'^[^:*]*$');
    });
    test('CloudWatchLargeMessages', () {
      expect(CloudWatchLargeMessages.values, [
        CloudWatchLargeMessages.truncate,
        CloudWatchLargeMessages.ignore,
        CloudWatchLargeMessages.split,
        CloudWatchLargeMessages.error,
      ]);
    });
  });
  group('CloudWatchException', () {
    group('constructors', () {
      test('minimum', () {
        CloudWatchException exception = CloudWatchException(
          message: 'message',
          stackTrace: StackTrace.empty,
        );
        expect(exception.type == null, true);
        expect(exception.raw == null, true);
      });
      test('maximum', () {
        CloudWatchException exception = CloudWatchException(
            message: 'message',
            stackTrace: StackTrace.empty,
            type: 'type',
            raw: 'raw');
        expect(exception.type, 'type');
        expect(exception.raw, 'raw');
      });
    });
    group('toString', () {
      test('minimum', () {
        CloudWatchException exception = CloudWatchException(
          message: 'message',
          stackTrace: StackTrace.empty,
        );
        expect(
          exception.toString(),
          "CloudWatchException - message: message",
        );
      });
      test('maximum', () {
        CloudWatchException exception = CloudWatchException(
            message: 'message',
            stackTrace: StackTrace.empty,
            type: 'type',
            raw: 'raw');
        expect(
          exception.toString(),
          "CloudWatchException - type: type, message: message",
        );
      });
    });
  });
  group('name validation', () {
    test('validateLogStreamName', () {
      try {
        validateLogStreamName('validateLogStreamName');
      } catch (e) {
        fail('"validateLogStreamName" failed validation');
      }
    });
    test('validateLogGroupName', () {
      try {
        validateLogGroupName('validateLogGroupName');
      } catch (e) {
        fail('"validateLogGroupName" failed validation');
      }
    });
    group('validateName', () {
      test('null name', () {
        try {
          validateName(null, 'type', r'');
        } catch (e) {
          expect(e, isA<CloudWatchException>());
          CloudWatchException error = e as CloudWatchException;
          expect(
            error.message,
            'No type name provided. Set type and then try again.',
          );
          return;
        }
        fail('validateName name cannot be null');
      });
      test('empty name', () {
        try {
          validateName('', 'type', r'');
        } catch (e) {
          expect(e, isA<CloudWatchException>());
          CloudWatchException error = e as CloudWatchException;
          expect(
            error.message,
            'Provided type "" is invalid. type must be between 1 and 512 characters.',
          );
          return;
        }
        fail('validateName name cannot be empty');
      });
      test('huge name', () {
        try {
          validateName('1' * 513, 'type', r'');
        } catch (e) {
          expect(e, isA<CloudWatchException>());
          CloudWatchException error = e as CloudWatchException;
          expect(
            error.message,
            'Provided type "${'1' * 513}" is invalid. type must be between 1 and 512 characters.',
          );
          return;
        }
        fail('validateName name cannot be bigger than 512 characters');
      });
      test('no regex match name', () {
        try {
          validateName('abc', 'type', r'\d');
        } catch (e) {
          expect(e, isA<CloudWatchException>());
          CloudWatchException error = e as CloudWatchException;
          expect(
            error.message,
            r'Provided type "abc" doesnt match pattern \d required of type',
          );
          return;
        }
        fail('validateName name must match provided regex');
      });
      test('good name', () {
        validateName('1', 'type', r'\d');
      });
    });
  });
  group('AwsResponse', () {
    group('parseResponse', () {
      test('empty body', () async {
        Response response = Response('', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type == null, true);
        expect(res.message == null, true);
        expect(res.nextSequenceToken == null, true);
        expect(res.expectedSequenceToken == null, true);
        expect(res.raw == null, true);
      });
      test('unknown element', () async {
        Response response = Response('{"a":"a"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type == null, true);
        expect(res.message == null, true);
        expect(res.nextSequenceToken == null, true);
        expect(res.expectedSequenceToken == null, true);
        expect(res.raw, '{a: a}');
      });
      test('type', () async {
        Response response = Response('{"__type":"type"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type, 'type');
        expect(res.message == null, true);
        expect(res.nextSequenceToken == null, true);
        expect(res.expectedSequenceToken == null, true);
        expect(res.raw, '{__type: type}');
      });
      test('message', () async {
        Response response = Response('{"message":"message"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type == null, true);
        expect(res.message, 'message');
        expect(res.nextSequenceToken == null, true);
        expect(res.expectedSequenceToken == null, true);
        expect(res.raw, '{message: message}');
      });
      test('nextSequenceToken', () async {
        Response response = Response(
          '{"nextSequenceToken":"nextSequenceToken"}',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type == null, true);
        expect(res.message == null, true);
        expect(res.nextSequenceToken, 'nextSequenceToken');
        expect(res.expectedSequenceToken == null, true);
        expect(res.raw, '{nextSequenceToken: nextSequenceToken}');
      });
      test('expectedSequenceToken', () async {
        Response response = Response(
          '{"expectedSequenceToken":"expectedSequenceToken"}',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type == null, true);
        expect(res.message == null, true);
        expect(res.nextSequenceToken == null, true);
        expect(res.expectedSequenceToken, 'expectedSequenceToken');
        expect(res.raw, '{expectedSequenceToken: expectedSequenceToken}');
      });
      test('all', () async {
        Response response = Response(
          '''{
          "__type":"type",
          "message":"message",
          "nextSequenceToken":"nextSequenceToken",
          "expectedSequenceToken":"expectedSequenceToken"
          }''',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.statusCode, 200);
        expect(res.type, 'type');
        expect(res.message, 'message');
        expect(res.nextSequenceToken, 'nextSequenceToken');
        expect(res.expectedSequenceToken, 'expectedSequenceToken');
        expect(
          res.raw,
          '{__type: type, message: message, '
          'nextSequenceToken: nextSequenceToken, '
          'expectedSequenceToken: expectedSequenceToken}',
        );
      });
    });
    group('toString', () {
      test('empty body', () async {
        Response response = Response('', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.toString(), 'AwsResponse - statusCode: 200');
      });
      test('unknown element', () async {
        Response response = Response('{"a":"a"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.toString(), 'AwsResponse - statusCode: 200');
      });
      test('type', () async {
        Response response = Response('{"__type":"type"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.toString(), 'AwsResponse - statusCode: 200, type: type');
      });
      test('message', () async {
        Response response = Response('{"message":"message"}', 200);
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(
            res.toString(), 'AwsResponse - statusCode: 200, message: message');
      });
      test('nextSequenceToken', () async {
        Response response = Response(
          '{"nextSequenceToken":"nextSequenceToken"}',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.toString(),
            'AwsResponse - statusCode: 200, nextSequenceToken: nextSequenceToken');
      });
      test('expectedSequenceToken', () async {
        Response response = Response(
          '{"expectedSequenceToken":"expectedSequenceToken"}',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(res.toString(),
            'AwsResponse - statusCode: 200, expectedSequenceToken: expectedSequenceToken');
      });
      test('all', () async {
        Response response = Response(
          '''{
          "__type":"type",
          "message":"message",
          "nextSequenceToken":"nextSequenceToken",
          "expectedSequenceToken":"expectedSequenceToken"
          }''',
          200,
        );
        AwsResponse res = await AwsResponse.parseResponse(response);
        expect(
          res.toString(),
          'AwsResponse - statusCode: 200, type: type, '
          'message: message, expectedSequenceToken: expectedSequenceToken, '
          'nextSequenceToken: nextSequenceToken',
        );
      });
    });
  });
}
