import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_smssettings/pip_services_smssettings.dart';
import './SmsSettingsPersistenceFixture.dart';

void main() {
  group('SmsSettingsMemoryPersistence', () {
    SmsSettingsMemoryPersistence persistence;
    SmsSettingsPersistenceFixture fixture;

    setUp(() async {
      persistence = SmsSettingsMemoryPersistence();
      persistence.configure(ConfigParams());

      fixture = SmsSettingsPersistenceFixture(persistence);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });
  });
}
