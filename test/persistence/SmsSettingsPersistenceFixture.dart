import 'package:test/test.dart';
import 'package:pip_services_smssettings/pip_services_smssettings.dart';

final SETTINGS1 = SmsSettingsV1(
    id: '1',
    name: 'User 1',
    phone: '+1234567890',
    language: 'en',
    verified: false,
    ver_code: null,
    subscriptions: {'notifications': true, 'ads': false});

class SmsSettingsPersistenceFixture {
  ISmsSettingsPersistence _persistence;

  SmsSettingsPersistenceFixture(ISmsSettingsPersistence persistence) {
    expect(persistence, isNotNull);
    _persistence = persistence;
  }

  void testCrudOperations() async {
    SmsSettingsV1 settings1;

    // Create items
    var settings = await _persistence.set(null, SETTINGS1);

    expect(settings, isNotNull);
    expect(SETTINGS1.id, settings.id);
    expect(SETTINGS1.phone, settings.phone);
    expect(SETTINGS1.name, settings.name);
    expect(settings.verified, isFalse);
    expect(settings.ver_code, isNull);

    // Get settings by sms
    settings = await _persistence.getOneByPhoneSettings(null, SETTINGS1.phone);
    expect(settings, isNotNull);
    expect(SETTINGS1.id, settings.id);
    expect(SETTINGS1.phone, settings.phone);

    settings1 = settings;

    // Update the settings
    settings1.phone = '+1234567432';

    settings = await _persistence.set(null, settings1);
    expect(settings, isNotNull);
    expect(settings1.id, settings.id);
    expect(settings.verified, isFalse);
    expect('+1234567432', settings.phone);

    // Get list of settings by ids
    var list = await _persistence.getListByIds(null, [SETTINGS1.id]);
    expect(list, isNotNull);
    expect(list.length, 1);

    // Delete the settings
    settings = await _persistence.deleteById(null, settings1.id);
    expect(settings, isNotNull);
    expect(settings1.id, settings.id);

    // Try to get deleted settings
    settings = await _persistence.getOneById(null, settings1.id);
    expect(settings, isNull);
  }
}
