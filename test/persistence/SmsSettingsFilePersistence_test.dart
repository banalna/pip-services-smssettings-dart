import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_smssettings/pip_services_smssettings.dart';
import './SmsSettingsPersistenceFixture.dart';

void main() {
  group('SmsSettingsFilePersistence', () {
    SmsSettingsFilePersistence persistence;
    SmsSettingsPersistenceFixture fixture;

    setUp(() async {
      persistence = SmsSettingsFilePersistence('data/sms_settings.test.json');
      persistence.configure(ConfigParams());

      fixture = SmsSettingsPersistenceFixture(persistence);

      await persistence.open(null);
      await persistence.clear(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });
  });
}
