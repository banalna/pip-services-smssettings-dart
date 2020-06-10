import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../persistence/SmsSettingsMemoryPersistence.dart';
import '../persistence/SmsSettingsFilePersistence.dart';
import '../persistence/SmsSettingsMongoDbPersistence.dart';
import '../logic/SmsSettingsController.dart';
import '../services/version1/SmsSettingsHttpServiceV1.dart';

class SmsSettingsServiceFactory extends Factory {
  static final MemoryPersistenceDescriptor = Descriptor(
      'pip-services-smssettings', 'persistence', 'memory', '*', '1.0');
  static final FilePersistenceDescriptor =
      Descriptor('pip-services-smssettings', 'persistence', 'file', '*', '1.0');
  static final MongoDbPersistenceDescriptor = Descriptor(
      'pip-services-smssettings', 'persistence', 'mongodb', '*', '1.0');
  static final ControllerDescriptor = Descriptor(
      'pip-services-smssettings', 'controller', 'default', '*', '1.0');
  static final HttpServiceDescriptor =
      Descriptor('pip-services-smssettings', 'service', 'http', '*', '1.0');

  SmsSettingsServiceFactory() : super() {
    registerAsType(SmsSettingsServiceFactory.MemoryPersistenceDescriptor,
        SmsSettingsMemoryPersistence);
    registerAsType(SmsSettingsServiceFactory.FilePersistenceDescriptor,
        SmsSettingsFilePersistence);
    registerAsType(SmsSettingsServiceFactory.MongoDbPersistenceDescriptor,
        SmsSettingsMongoDbPersistence);
    registerAsType(
        SmsSettingsServiceFactory.ControllerDescriptor, SmsSettingsController);
    registerAsType(SmsSettingsServiceFactory.HttpServiceDescriptor,
        SmsSettingsHttpServiceV1);
  }
}
