//import 'package:pip_clients_sms/pip_clients_sms.dart';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_smssettings/pip_services_smssettings.dart';

final SETTINGS = SmsSettingsV1(
    id: '1',
    name: 'User 1',
    phone: '+1234567890',
    language: 'en',
    verified: false);

final SETTINGS2 = SmsSettingsV1(
    id: '2',
    name: 'User 2',
    phone: '+0987654321',
    language: 'en',
    verified: false);

void main() {
  group('SmsSettingsController', () {
    SmsSettingsMemoryPersistence persistence;
    SmsSettingsController controller;

    setUp(() async {
      persistence = SmsSettingsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = SmsSettingsController();
      controller.configure(ConfigParams());

      var references = References.fromTuples([
        Descriptor('pip-services-smssettings', 'persistence', 'memory',
            'default', '1.0'),
        persistence,
        Descriptor('pip-services-smssettings', 'controller', 'default',
            'default', '1.0'),
        controller
        // Descriptor('pip-services-sms', 'client', 'null', 'default', '1.0'),
        // SmsNullClientV1()
      ]);

      controller.setReferences(references);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      SmsSettingsV1 settings1;

      // Create phone settings
      var settings = await controller.setSettings(null, SETTINGS);
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(SETTINGS.phone, settings.phone);
      expect(settings.verified, isFalse);

      settings1 = settings;

      // Update the settings
      settings1.subscriptions = {'engagement': true};

      settings = await controller.setSettings(null, settings1);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.subscriptions['engagement'], isTrue);

      // Get settings
      var list = await controller.getSettingsByIds(null, [settings1.id]);
      expect(list, isNotNull);
      expect(list.length, 1);

      // Delete the settings
      settings = await controller.deleteSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);

      // Try to get deleted settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNull);
    });

    test('Verify Phone', () async {
      SmsSettingsV1 settings1;

      // Create new settings
      settings1 = SETTINGS;
      settings1.ver_code = '123';
      settings1.verified = false;
      settings1.ver_expire_time = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch + 10000);

      var settings = await persistence.set(null, settings1);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNotNull);

      // Verify phone
      await controller.verifyPhone(null, settings1.id, settings1.ver_code);

      // Check settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(settings.verified, isTrue);
      expect(settings.ver_code, isNull);
    });

    test('Resend Verification Sms', () async {
      SmsSettingsV1 settings1;

      // Create new settings
      var settings = await persistence.set(null, SETTINGS2);
      expect(settings, isNotNull);
      expect(SETTINGS2.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNull);

      settings1 = settings;

      // Verify phone
      await controller.resendVerification(null, settings1.id);

      // Check settings
      settings = await controller.getSettingsById(null, settings1.id);
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.verified, isFalse);
      expect(settings.ver_code, isNull);
    });
  });
}
