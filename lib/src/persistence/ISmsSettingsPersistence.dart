import 'dart:async';
import '../data/version1/SmsSettingsV1.dart';

abstract class ISmsSettingsPersistence {
  Future<List<SmsSettingsV1>> getListByIds(
      String correlationId, List<String> ids);

  Future<SmsSettingsV1> getOneById(String correlationId, String id);

  Future<SmsSettingsV1> getOneByPhoneSettings(
      String correlationId, String phone);

  Future<SmsSettingsV1> set(String correlationId, SmsSettingsV1 item);

  Future<SmsSettingsV1> deleteById(String correlationId, String id);
}
