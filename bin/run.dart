import 'package:pip_services_smssettings/pip_services_smssettings.dart';

void main(List<String> argument) {
  try {
    var proc = SmsSettingsProcess();
    proc.configPath = './config/config.yml';
    proc.run(argument);
  } catch (ex) {
    print(ex);
  }
}
