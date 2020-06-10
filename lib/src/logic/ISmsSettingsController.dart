import 'dart:async';
import '../../src/data/version1/SmsSettingsV1.dart';

abstract class ISmsSettingsController {
  /// Gets a list of sms settings retrieved by ids.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientIds]            a recipient ids to get settings
  /// Return         Future that receives a data list
  /// Throws error.
  Future<List<SmsSettingsV1>> getSettingsByIds(
      String correlationId, List<String> recipientIds);

  /// Gets a sms settings by recipient id.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// Return         Future that receives sms settings or error.
  Future<SmsSettingsV1> getSettingsById(
      String correlationId, String recipientId);

  /// Gets a sms settings by its phone.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [phone]                a phone of sms settings to be retrieved.
  /// Return         Future that receives sms settings or error.
  Future<SmsSettingsV1> getSettingsByPhoneSettings(
      String correlationId, String phone);

  /// Sets a sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              a sms settings to be set.
  /// Return         (optional) Future that receives set sms settings or error.
  Future<SmsSettingsV1> setSettings(
      String correlationId, SmsSettingsV1 settings);

  /// Sets a verified sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              a sms settings to be set.
  /// Return         (optional) Future that receives set verified sms settings or error.
  Future<SmsSettingsV1> setVerifiedSettings(
      String correlationId, SmsSettingsV1 settings);

  /// Sets a recipient info into sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [name]                a recipient name of settings to be set.
  /// - [phone]                a recipient phone of settings to be set.
  /// - [language]                a recipient language of settings to be set.
  /// Return         (optional) Future that receives updated sms settings
  /// Throws error.
  Future<SmsSettingsV1> setRecipient(String correlationId, String recipientId,
      String name, String phone, String language);

  /// Sets a subscriptions into sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [subscriptions]                a subscriptions to be set.
  /// Return         (optional) Future that receives updated sms settings
  /// Throws error.
  Future<SmsSettingsV1> setSubscriptions(
      String correlationId, String recipientId, dynamic subscriptions);

  /// Deletes a sms settings by recipient id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be deleted
  /// Return                Future that receives deleted sms settings
  /// Throws error.
  Future<SmsSettingsV1> deleteSettingsById(
      String correlationId, String recipientId);

  /// Resends verification.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be resend verification
  /// Return                Future that receives null for success.
  /// Throws error.
  Future resendVerification(String correlationId, String recipientId);

  /// Verifies a phone.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be verified phone
  /// - [code]                a verification code for verifying phone
  /// Return                Future that receives null for success.
  /// Throws error.
  Future verifyPhone(String correlationId, String recipientId, String code);
}
