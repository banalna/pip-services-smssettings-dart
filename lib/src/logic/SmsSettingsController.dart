import 'dart:async';

import 'package:pip_clients_msgtemplates/pip_clients_msgtemplates.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_clients_activities/pip_clients_activities.dart';
import 'package:pip_services_activities/pip_services_activities.dart';

import '../../src/data/version1/SmsSettingsV1.dart';
import '../../src/data/version1/SmsSettingsActivityTypeV1.dart';
import '../../src/persistence/ISmsSettingsPersistence.dart';
import './ISmsSettingsController.dart';
import './SmsSettingsCommandSet.dart';

class SmsSettingsController
    implements
        ISmsSettingsController,
        IConfigurable,
        IReferenceable,
        ICommandable {
  static final RegExp _phoneRegex = RegExp(r'^\+[0-9]{10,15}$');
  static final ConfigParams _defaultConfig = ConfigParams.fromTuples([
    'dependencies.persistence',
    'pip-services-smssettings:persistence:*:*:1.0',
    'dependencies.activities',
    'pip-services-activities:client:*:*:1.0',
    'dependencies.msgtemplates',
    'pip-services-msgtemplates:client:*:*:1.0',
    'dependencies.smsdelivery',
    'pip-services-sms:client:*:*:1.0',
    'message_templates.verify_phone.subject',
    'Verify phone number',
    'message_templates.verify_phone.text',
    'Verification code for {{phone}} is {{ code }}.',
    'options.magic_code',
    null,
    'options.signature_length',
    100,
    'options.verify_on_create',
    true,
    'options.verify_on_update',
    true
  ]);

  bool _verifyOnCreate = true;
  bool _verifyOnUpdate = true;
  num _expireTimeout = 24 * 60; // in minutes
  String _magicCode = '';
  //ConfigParams _config = ConfigParams();

  DependencyResolver dependencyResolver =
      DependencyResolver(SmsSettingsController._defaultConfig);
  final MessageTemplatesResolverV1 _templatesResolver =
      MessageTemplatesResolverV1();
  final CompositeLogger _logger = CompositeLogger();
  IActivitiesClientV1 _activitiesClient;
  // ISmsClientV1 _smsClient;
  ISmsSettingsPersistence persistence;
  SmsSettingsCommandSet commandSet;

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    config = config.setDefaults(SmsSettingsController._defaultConfig);
    dependencyResolver.configure(config);

    _templatesResolver.configure(config);
    _logger.configure(config);

    _verifyOnCreate = config.getAsBooleanWithDefault(
        'options.verify_on_create', _verifyOnCreate);
    _verifyOnUpdate = config.getAsBooleanWithDefault(
        'options.verify_on_update', _verifyOnUpdate);
    _expireTimeout = config.getAsIntegerWithDefault(
        'options.verify_expire_timeout', _expireTimeout);
    _magicCode =
        config.getAsStringWithDefault('options.magic_code', _magicCode);
  }

  /// Set references to component.
  ///
  /// - [references]    references parameters to be set.
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    dependencyResolver.setReferences(references);
    _templatesResolver.setReferences(references);

    persistence = dependencyResolver
        .getOneRequired<ISmsSettingsPersistence>('persistence');
    _activitiesClient =
        dependencyResolver.getOneOptional<IActivitiesClientV1>('activities');
    // _smsClient =
    //     dependencyResolver.getOneOptional<ISmsClientV1>('smsdelivery');
  }

  /// Gets a command set.
  ///
  /// Return Command set
  @override
  CommandSet getCommandSet() {
    commandSet ??= SmsSettingsCommandSet(this);
    return commandSet;
  }

  SmsSettingsV1 _settingsToPublic(SmsSettingsV1 settings) {
    if (settings == null) return null;

    settings.ver_code = null;
    settings.ver_expire_time = null;
    return settings;
  }

  /// Gets a list of sms settings retrieved by a ids.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientIds]            a recipient ids to get settings
  /// Return         Future that receives a data list
  /// Throws error.
  @override
  Future<List<SmsSettingsV1>> getSettingsByIds(
      String correlationId, List<String> recipientIds) async {
    var settings = await persistence.getListByIds(correlationId, recipientIds);
    var result = <SmsSettingsV1>[];
    if (settings != null) {
      result = settings.map((s) => _settingsToPublic(s)).toList();
    }
    return result;
  }

  /// Gets a sms settings by recipient id.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// Return         Future that receives sms settings or error.
  @override
  Future<SmsSettingsV1> getSettingsById(
      String correlationId, String recipientId) async {
    var settings = await persistence.getOneById(correlationId, recipientId);
    return _settingsToPublic(settings);
  }

  /// Gets a sms settings by its phone.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [phone]                a phone of sms settings to be retrieved.
  /// Return         Future that receives sms settings or error.
  @override
  Future<SmsSettingsV1> getSettingsByPhoneSettings(
      String correlationId, String phone) async {
    var settings =
        await persistence.getOneByPhoneSettings(correlationId, phone);
    return _settingsToPublic(settings);
  }

  Future<SmsSettingsV1> _verifyAndSaveSettings(String correlationId,
      SmsSettingsV1 oldSettings, SmsSettingsV1 newSettings) async {
    var verify = false;

    // Check if verification is needed
    verify = (oldSettings == null && _verifyOnCreate) ||
        (oldSettings.phone != newSettings.phone && _verifyOnUpdate);
    if (verify) {
      newSettings.verified = false;
      var code = IdGenerator.nextShort();
      newSettings.ver_code = code.substring(0, 4);
      newSettings.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch + _expireTimeout * 60000);
    }

    // Set new settings
    var data = await persistence.set(correlationId, newSettings);

    // Send verification if needed
    // Send verification message and do not wait
    if (verify) {
      await _sendVerificationMessage(correlationId, newSettings);
    }

    return data;
  }

  Future<void> _sendVerificationMessage(
      String correlationId, SmsSettingsV1 newSettings) async {
    var template = await _templatesResolver.resolve('verify_phone');
    var err;
    if (template == null) {
      err = ConfigException(correlationId, 'MISSING_VERIFY_PHONE',
          'Message template "verify_phone" is missing');
    }

    if (err != null) {
      _logger.error(
          correlationId, err, 'Cannot find verify_phone message template');
      return;
    }

    // var message = SmsMessageV1(
    //     subject: template.subject, text: template.text, html: template.html);

    // var recipient = SmsRecipientV1(
    //     id: newSettings.id,
    //     name: newSettings.name,
    //     phone: newSettings.phone,
    //     language: newSettings.language);

    // var parameters = ConfigParams.fromTuples(
    //     ['code', newSettings.ver_code]);

    // if (_smsClient != null) {
    //   await _smsClient.sendMessageToRecipient(
    //       correlationId, recipient, message, parameters);
    // }
  }

  void _logActivity(
      String correlationId, SmsSettingsV1 settings, String activityType) {
    if (_activitiesClient != null) {
      var activity = _activitiesClient.logPartyActivity(
          correlationId,
          PartyActivityV1(
              id: null,
              type: activityType,
              party: ReferenceV1(
                  id: settings.id, type: 'account', name: settings.name)));
      if (activity == null) {
        var err = BadRequestException(
            correlationId, 'NULL_ACTIVITY', 'Failed logPartyActivity');
        _logger.error(correlationId, err, 'Failed to log user activity');
      }
    }
  }

  /// Sets a sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              a sms settings to be set.
  /// Return         (optional) Future that receives set sms settings or error.
  @override
  Future<SmsSettingsV1> setSettings(
      String correlationId, SmsSettingsV1 settings) async {
    if (settings.id == null) {
      throw BadRequestException(
          correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (settings.phone == null) {
      throw BadRequestException(correlationId, 'NO_PHONE', 'Missing phone');
    }

    if (!SmsSettingsController._phoneRegex.hasMatch(settings.phone)) {
      var err = BadRequestException(
              correlationId, 'WRONG_PHONE', 'Invalid phone ' + settings.phone)
          .withDetails('phone', settings.phone);
      _logger.trace(correlationId, 'Settings is not valid %s', [err]);
      return null;
    }

    var newSettings = settings;
    newSettings.verified = false;
    newSettings.ver_code = null;
    newSettings.ver_expire_time = null;
    newSettings.subscriptions = newSettings.subscriptions ?? {};

    var oldSettings = SmsSettingsV1();
    oldSettings = await persistence.getOneById(correlationId, newSettings.id);

    if (oldSettings != null) {
      // Override
      newSettings.verified = oldSettings.verified;
      newSettings.ver_code = oldSettings.ver_code;
      newSettings.ver_expire_time = oldSettings.ver_expire_time;
    }

    // Verify and save settings
    var data =
        await _verifyAndSaveSettings(correlationId, oldSettings, newSettings);

    // remove ver_code from returned data
    data.ver_code = null;

    return data;
  }

  /// Sets a verified sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [settings]              an sms settings to be set.
  /// Return         (optional) Future that receives set verified sms settings or error.
  @override
  Future<SmsSettingsV1> setVerifiedSettings(
      String correlationId, SmsSettingsV1 settings) {
    if (settings.id == null) {
      throw BadRequestException(
          correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (settings.phone == null) {
      throw BadRequestException(correlationId, 'NO_PHONE', 'Missing phone');
    }

    if (!SmsSettingsController._phoneRegex.hasMatch(settings.phone)) {
      var err = BadRequestException(
              correlationId, 'WRONG_PHONE', 'Invalid phone ' + settings.phone)
          .withDetails('phone', settings.phone);
      _logger.trace(correlationId, 'Settings is not valid %s', [err]);
      return null;
    }

    var newSettings = settings;
    newSettings.verified = true;
    newSettings.ver_code = null;
    newSettings.ver_expire_time = null;
    newSettings.subscriptions = newSettings.subscriptions ?? {};

    return persistence.set(correlationId, newSettings);
  }

  /// Sets a recipient info into sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [name]                a recipient name of settings to be set.
  /// - [phone]                a recipient phone of settings to be set.
  /// - [language]                a recipient language of settings to be set.
  /// Return         (optional) Future that receives updated sms settings
  /// Throws error.
  @override
  Future<SmsSettingsV1> setRecipient(String correlationId, String recipientId,
      String name, String phone, String language) async {
    if (recipientId == null) {
      throw BadRequestException(
          correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    if (phone == null) {
      throw BadRequestException(correlationId, 'NO_PHONE', 'Missing phone');
    }

    if (phone != null && !SmsSettingsController._phoneRegex.hasMatch(phone)) {
      var err = BadRequestException(
              correlationId, 'WRONG_PHONE', 'Invalid phone ' + phone)
          .withDetails('phone', phone);
      _logger.trace(correlationId, 'Sms is not valid %s', [err]);
      return null;
    }

    var oldSettings = SmsSettingsV1();
    var newSettings = SmsSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data != null) {
      // Copy and modify existing settings
      oldSettings = data;
      newSettings = data;
      newSettings.name = name ?? data.name;
      newSettings.phone = phone ?? data.phone;
      newSettings.language = language ?? data.language;
    } else {
      // Create new settings if they are not exist
      oldSettings = null;
      newSettings = SmsSettingsV1(
          id: recipientId, name: name, phone: phone, language: language);
    }

    // Verify and save settings
    data =
        await _verifyAndSaveSettings(correlationId, oldSettings, newSettings);

    // remove ver_code from returned data
    data.ver_code = null;

    return data;
  }

  /// Sets a subscriptions into sms settings.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of settings to be retrieved.
  /// - [subscriptions]                a subscriptions to be set.
  /// Return         (optional) Future that receives updated sms settings
  /// Throws error.
  @override
  Future<SmsSettingsV1> setSubscriptions(
      String correlationId, String recipientId, dynamic subscriptions) async {
    if (recipientId == null) {
      throw BadRequestException(
          correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    var oldSettings = SmsSettingsV1();
    var newSettings = SmsSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data != null) {
      // Copy and modify existing settings
      oldSettings = data;
      newSettings = data;
      newSettings.subscriptions = subscriptions ?? data.subscriptions;
    } else {
      // Create new settings if they are not exist
      oldSettings = null;
      newSettings = SmsSettingsV1(
          id: recipientId,
          name: null,
          phone: null,
          language: null,
          subscriptions: subscriptions);
    }

    // Verify and save settings
    data =
        await _verifyAndSaveSettings(correlationId, oldSettings, newSettings);

    // remove ver_code from returned data
    data.ver_code = null;

    return data;
  }

  /// Deletes a sms settings by recipient id.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be deleted
  /// Return                Future that receives deleted sms settings
  /// Throws error.
  @override
  Future<SmsSettingsV1> deleteSettingsById(
      String correlationId, String recipientId) {
    return persistence.deleteById(correlationId, recipientId);
  }

  /// Resends verification.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be resend verification
  /// Return                Future that receives null for success.
  /// Throws error.
  @override
  Future resendVerification(String correlationId, String recipientId) async {
    if (recipientId == null) {
      throw BadRequestException(
          correlationId, 'NO_RECIPIENT_ID', 'Missing recipient id');
    }

    var settings = SmsSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data == null) {
      throw NotFoundException(correlationId, 'RECIPIENT_NOT_FOUND',
              'Recipient ' + recipientId + ' was not found')
          .withDetails('recipient_id', recipientId);
    }

    settings = data;
    // Check if verification is needed
    settings.verified = false;
    var code = IdGenerator.nextShort();
    settings.ver_code = code.substring(0, 4);
    settings.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch + _expireTimeout * 60000);

    // Set new settings
    data = await persistence.set(correlationId, settings);

    // Send verification
    await _sendVerificationMessage(correlationId, settings);
  }

  /// Verifies a phone.
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipientId]                a recipient id of the sms settings to be verified sms
  /// - [code]                a verification code for verifying sms
  /// Return                Future that receives null for success.
  /// Throws error.
  @override
  Future verifyPhone(
      String correlationId, String recipientId, String code) async {
    var settings = SmsSettingsV1();

    // Get existing settings
    var data = await persistence.getOneById(correlationId, recipientId);
    if (data == null) {
      throw NotFoundException(correlationId, 'RECIPIENT_NOT_FOUND',
              'Recipient ' + recipientId + ' was not found')
          .withDetails('recipient_id', recipientId);
    }

    settings = data;

    // Check and update verification code
    var verified = settings.ver_code == code;
    verified = verified || (_magicCode != null && code == _magicCode);
    verified = verified &&
        DateTime.now().millisecondsSinceEpoch <
            DateTime.fromMillisecondsSinceEpoch(
                    settings.ver_expire_time.millisecondsSinceEpoch)
                .millisecondsSinceEpoch;

    if (!verified) {
      throw BadRequestException(correlationId, 'INVALID_CODE',
              'Invalid sms verification code ' + code)
          .withDetails('recipient_id', recipientId)
          .withDetails('code', code);
    }

    settings.verified = true;
    settings.ver_code = null;
    settings.ver_expire_time = null;

    // Save user
    data = await persistence.set(correlationId, settings);

    // Asynchronous post-processing
    _logActivity(
        correlationId, settings, SmsSettingsActivityTypeV1.PhoneVerified);
  }
}
