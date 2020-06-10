import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

class SmsSettingsHttpServiceV1 extends CommandableHttpService {
  SmsSettingsHttpServiceV1() : super('v1/sms_settings') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-smssettings', 'controller', '*', '*', '1.0'));
  }
}
