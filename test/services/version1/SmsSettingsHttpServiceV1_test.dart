import 'dart:convert';
//import 'package:pip_clients_sms/pip_clients_sms.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_smssettings/pip_services_smssettings.dart';

final SETTINGS = SmsSettingsV1(
    id: '1',
    name: 'User 1',
    phone: '+1234567890',
    language: 'en',
    verified: false);

var httpConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('SmsSettingsHttpServiceV1', () {
    SmsSettingsMemoryPersistence persistence;
    SmsSettingsController controller;
    SmsSettingsHttpServiceV1 service;
    http.Client rest;
    String url;

    setUp(() async {
      url = 'http://localhost:3000';
      rest = http.Client();

      persistence = SmsSettingsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = SmsSettingsController();
      controller.configure(ConfigParams());

      service = SmsSettingsHttpServiceV1();
      service.configure(httpConfig);

      var references = References.fromTuples([
        Descriptor('pip-services-smssettings', 'persistence', 'memory',
            'default', '1.0'),
        persistence,
        Descriptor('pip-services-smssettings', 'controller', 'default',
            'default', '1.0'),
        controller,
        // Descriptor('pip-services-sms', 'client', 'null', 'default', '1.0'),
        // SmsNullClientV1(),
        Descriptor(
            'pip-services-smssettings', 'service', 'http', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);
      await service.open(null);
    });

    tearDown(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      SmsSettingsV1 settings1;

      // Create sms settings
      var resp = await rest.post(url + '/v1/sms_settings/set_settings',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'settings': SETTINGS}));
      var settings = SmsSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(SETTINGS.id, settings.id);
      expect(SETTINGS.phone, settings.phone);
      expect(settings.verified, isFalse);

      settings1 = settings;

      // Update the settings
      settings1.subscriptions = {'engagement': true};

      resp = await rest.post(url + '/v1/sms_settings/set_settings',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'settings': settings1}));
      settings = SmsSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);
      expect(settings.subscriptions['engagement'], isTrue);

      // Get settings
      resp = await rest.post(url + '/v1/sms_settings/get_settings_by_ids',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'recipient_ids': [settings1.id]
          }));
      var list = List<SmsSettingsV1>.from(json
          .decode(resp.body)
          .map((itemsJson) => SmsSettingsV1.fromJson(itemsJson)));
      expect(list, isNotNull);
      expect(list.length, 1);

      // Delete the settings
      resp = await rest.post(url + '/v1/sms_settings/delete_settings_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'recipient_id': settings1.id}));
      settings = SmsSettingsV1();
      settings.fromJson(json.decode(resp.body));
      expect(settings, isNotNull);
      expect(settings1.id, settings.id);

      // Try to get deleted settings
      resp = await rest.post(url + '/v1/sms_settings/get_settings_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'recipient_id': settings1.id}));
      expect(resp.body, isEmpty);
    });
  });
}
