// Copyright (c) 2021, Zachary Merritt.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

library CloudWatchHandler;

import 'aws_cloudwatch.dart';
import 'src/cloudwatch_handler.dart' show AwsCloudWatchHandler;

export 'src/util.dart' show CloudWatchLargeMessages, CloudWatchException;

/// A CloudWatch handler class to easily manage multiple CloudWatch instances
class CloudWatchHandler {
  /// Your AWS access key
  String get awsAccessKey => _handler.awsAccessKey;

  set awsAccessKey(String key) => _handler.awsAccessKey = key;

  /// Your AWS secret key
  String get awsSecretKey => _handler.awsSecretKey;

  set awsSecretKey(String key) => _handler.awsSecretKey = key;

  /// Your AWS session token
  String? get awsSessionToken => _handler.awsSessionToken;

  set awsSessionToken(String? token) => _handler.awsSessionToken = token;

  /// Your AWS region. Instances are not updated when this value is changed
  String get region => _handler.region;

  set region(String region) => _handler.region = region;

  /// How long to wait between requests to avoid rate limiting (suggested value is Duration(milliseconds: 200))
  Duration get delay => _handler.delay;

  set delay(Duration val) => _handler.delay = val;

  /// How long to wait for request before triggering a timeout
  Duration get requestTimeout => _handler.requestTimeout;

  set requestTimeout(Duration val) => _handler.requestTimeout = val;

  /// How many times an api request should be retired upon failure. Default is 3
  int get retries => _handler.retries;

  set retries(int val) => _handler.retries = val;

  /// How messages larger than AWS limit should be handled. Default is truncate.
  CloudWatchLargeMessages get largeMessageBehavior =>
      _handler.largeMessageBehavior;

  set largeMessageBehavior(CloudWatchLargeMessages val) =>
      _handler.largeMessageBehavior = val;

  /// Whether exceptions should be raised on failed lookups (usually no internet)
  bool get raiseFailedLookups => _handler.raiseFailedLookups;

  /// Whether exceptions should be raised on failed lookups (usually no internet)
  set raiseFailedLookups(bool val) => _handler.raiseFailedLookups = val;

  AwsCloudWatchHandler _handler;

  /// CloudWatchHandler Constructor
  CloudWatchHandler({
    required awsAccessKey,
    required awsSecretKey,
    required region,
    awsSessionToken: null,
    delay: const Duration(),
    requestTimeout: const Duration(seconds: 10),
    retries: 3,
    largeMessageBehavior: CloudWatchLargeMessages.truncate,
    raiseFailedLookups: false,
  }) : _handler = AwsCloudWatchHandler(
          awsAccessKey: awsAccessKey,
          awsSecretKey: awsSecretKey,
          region: region,
          awsSessionToken: awsSessionToken,
          delay: delay,
          requestTimeout: requestTimeout,
          retries: retries,
          largeMessageBehavior: largeMessageBehavior,
          raiseFailedLookups: raiseFailedLookups,
        );

  /// Returns a specific instance of a CloudWatch class (or null if it doesn't
  /// exist) based on group name and stream name
  ///
  /// Uses the [logGroupName] and the [logStreamName] to find the correct
  /// CloudWatch instance. Returns null if it doesn't exist
  CloudWatch? getInstance({
    required String logGroupName,
    required String logStreamName,
  }) {
    return _handler.getInstance(
      logGroupName: logGroupName,
      logStreamName: logStreamName,
    ) as CloudWatch;
  }

  /// Logs the provided message to the provided log group and log stream
  ///
  /// Logs a single [msg] to [logStreamName] under the group [logGroupName]
  void log({
    required String msg,
    required String logGroupName,
    required String logStreamName,
  }) {
    _handler.log(
      msg: msg,
      logGroupName: logGroupName,
      logStreamName: logStreamName,
    );
  }

  /// Logs the provided message to the provided log group and log stream
  ///
  /// Logs a list of string [messages] to [logStreamName] under the group [logGroupName]
  ///
  /// Note: using logMany will result in all logs having the same timestamp
  void logMany({
    required List<String> messages,
    required String logGroupName,
    required String logStreamName,
  }) {
    _handler.logMany(
      messages: messages,
      logGroupName: logGroupName,
      logStreamName: logStreamName,
    );
  }

  /// Creates a CloudWatch instance.
  ///
  /// Calling any log function will call this as needed automatically
  CloudWatch createInstance({
    required String logGroupName,
    required String logStreamName,
  }) {
    return _handler.createInstance(
      logGroupName: logGroupName,
      logStreamName: logStreamName,
    ) as CloudWatch;
  }
}
