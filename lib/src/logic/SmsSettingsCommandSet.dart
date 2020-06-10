import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../src/data/version1/SmsSettingsV1Schema.dart';
import '../../src/logic/ISmsSettingsController.dart';
import '../../src/data/version1/SmsSettingsV1.dart';

class SmsSettingsCommandSet extends CommandSet {
  ISmsSettingsController _controller;

  SmsSettingsCommandSet(ISmsSettingsController controller) : super() {
    _controller = controller;

    addCommand(_makeGetSettingsByIdsCommand());
    addCommand(_makeGetSettingsByIdCommand());
    addCommand(_makeGetSettingsByPhoneSettingsCommand());
    addCommand(_makeSetSettingsCommand());
    addCommand(_makeSetVerifiedSettingsCommand());
    addCommand(_makeSetRecipientCommand());
    addCommand(_makeSetSubscriptionsCommand());
    addCommand(_makeDeleteSettingsByIdCommand());
    addCommand(_makeResendVerificationCommand());
    addCommand(_makeVerifySmsCommand());
  }

  ICommand _makeGetSettingsByIdsCommand() {
    return Command(
        'get_settings_by_ids',
        ObjectSchema(true).withRequiredProperty(
            'recipient_ids', ArraySchema(TypeCode.String)),
        (String correlationId, Parameters args) {
      var recipientIds = List<String>.from(args.get('recipient_ids'));
      return _controller.getSettingsByIds(correlationId, recipientIds);
    });
  }

  ICommand _makeGetSettingsByIdCommand() {
    return Command(
        'get_settings_by_id',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsNullableString('recipient_id');
      return _controller.getSettingsById(correlationId, recipientId);
    });
  }

  ICommand _makeGetSettingsByPhoneSettingsCommand() {
    return Command('get_settings_by_phone',
        ObjectSchema(true).withRequiredProperty('phone', TypeCode.String),
        (String correlationId, Parameters args) {
      var phone = args.getAsString('phone');
      return _controller.getSettingsByPhoneSettings(correlationId, phone);
    });
  }

  ICommand _makeSetSettingsCommand() {
    return Command(
        'set_settings',
        ObjectSchema(true)
            .withRequiredProperty('settings', SmsSettingsV1Schema()),
        (String correlationId, Parameters args) {
      var settings = SmsSettingsV1();
      settings.fromJson(args.get('settings'));
      return _controller.setSettings(correlationId, settings);
    });
  }

  ICommand _makeSetVerifiedSettingsCommand() {
    return Command(
        'set_verified_settings',
        ObjectSchema(true)
            .withRequiredProperty('settings', SmsSettingsV1Schema()),
        (String correlationId, Parameters args) {
      var settings = SmsSettingsV1();
      settings.fromJson(args.get('settings'));
      return _controller.setVerifiedSettings(correlationId, settings);
    });
  }

  ICommand _makeSetRecipientCommand() {
    return Command(
        'set_recipient',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String)
            .withOptionalProperty('name', TypeCode.String)
            .withOptionalProperty('phone', TypeCode.String)
            .withOptionalProperty('language', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var name = args.getAsString('name');
      var phone = args.getAsString('phone');
      var language = args.getAsString('language');
      return _controller.setRecipient(
          correlationId, recipientId, name, phone, language);
    });
  }

  ICommand _makeSetSubscriptionsCommand() {
    return Command(
        'set_subscriptions',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String)
            .withRequiredProperty('subscriptions', TypeCode.Map),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var subscriptions = args.get('subscriptions');
      return _controller.setSubscriptions(
          correlationId, recipientId, subscriptions);
    });
  }

  ICommand _makeDeleteSettingsByIdCommand() {
    return Command(
        'delete_settings_by_id',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsNullableString('recipient_id');
      return _controller.deleteSettingsById(correlationId, recipientId);
    });
  }

  ICommand _makeResendVerificationCommand() {
    return Command('resend_verification', ObjectSchema(),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      return _controller.resendVerification(correlationId, recipientId);
    });
  }

  ICommand _makeVerifySmsCommand() {
    return Command(
        'verify_phone',
        ObjectSchema(true)
            .withRequiredProperty('recipient_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var recipientId = args.getAsString('recipient_id');
      var code = args.getAsString('code');
      return _controller.verifyPhone(correlationId, recipientId, code);
    });
  }
}
