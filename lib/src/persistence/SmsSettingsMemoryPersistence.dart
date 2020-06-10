import 'dart:async';
import 'package:pip_services3_data/pip_services3_data.dart';
import '../data/version1/SmsSettingsV1.dart';
import './ISmsSettingsPersistence.dart';

class SmsSettingsMemoryPersistence
    extends IdentifiableMemoryPersistence<SmsSettingsV1, String>
    implements ISmsSettingsPersistence {
  SmsSettingsMemoryPersistence() : super() {
    maxPageSize = 1000;
  }

  @override
  Future<SmsSettingsV1> getOneByPhoneSettings(
      String correlationId, String phone) async {
    var item =
        items.isNotEmpty ? items.where((item) => item.phone == phone) : null;

    if (item != null && item.isNotEmpty && item.first != null) {
      logger.trace(correlationId, 'Found item by %s', [phone]);
    } else {
      logger.trace(correlationId, 'Cannot find item by %s', [phone]);
    }

    if (item != null && item.isNotEmpty && item.first != null) {
      return item.first;
    } else {
      return null;
    }
  }
}
