import 'package:pip_services3_data/pip_services3_data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/SmsSettingsV1.dart';
import './SmsSettingsMemoryPersistence.dart';

class SmsSettingsFilePersistence extends SmsSettingsMemoryPersistence {
  JsonFilePersister<SmsSettingsV1> persister;

  SmsSettingsFilePersistence([String path]) : super() {
    persister = JsonFilePersister<SmsSettingsV1>(path);
    loader = persister;
    saver = persister;
  }
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    persister.configure(config);
  }
}
