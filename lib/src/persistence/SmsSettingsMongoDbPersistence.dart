import 'dart:async';
import 'package:mongo_dart_query/mongo_dart_query.dart' as mngquery;
import 'package:pip_services3_mongodb/pip_services3_mongodb.dart';

import '../data/version1/SmsSettingsV1.dart';
import './ISmsSettingsPersistence.dart';

class SmsSettingsMongoDbPersistence
    extends IdentifiableMongoDbPersistence<SmsSettingsV1, String>
    implements ISmsSettingsPersistence {
  SmsSettingsMongoDbPersistence() : super('sms_settings') {
    maxPageSize = 1000;
  }

  @override
  Future<SmsSettingsV1> getOneByPhoneSettings(
      String correlationId, String phone) async {
    var filter = {'phone': phone};
    var query = mngquery.SelectorBuilder();
    var selector = <String, dynamic>{};
    if (filter != null && filter.isNotEmpty) {
      selector[r'$query'] = filter;
    }
    query.raw(selector);

    var item = await collection.findOne(filter);

    if (item == null) {
      logger.trace(correlationId, 'Nothing found from %s with login = %s',
          [collectionName, phone]);
      return null;
    }
    logger.trace(correlationId, 'Retrieved from %s with login = %s',
        [collectionName, phone]);
    return convertToPublic(item);
  }
}
