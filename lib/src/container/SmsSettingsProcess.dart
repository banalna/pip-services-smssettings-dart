import 'package:pip_clients_activities/pip_clients_activities.dart';
//import 'package:pip_clients_sms/pip_clients_sms.dart';
import 'package:pip_clients_msgtemplates/pip_clients_msgtemplates.dart';
import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import '../build/SmsSettingsServiceFactory.dart';

class SmsSettingsProcess extends ProcessContainer {
  SmsSettingsProcess() : super('sms_settings', 'Sms Settings microservice') {
    factories.add(SmsSettingsServiceFactory());
    factories.add(ActivitiesClientFactory());
    factories.add(MessageTemplatesClientFactory());
    //factories.add(SmsClientFactory());
    factories.add(DefaultRpcFactory());
  }
}
