# <img src="https://github.com/pip-services/pip-services/raw/master/design/Logo.png" alt="Pip.Services Logo" style="max-width:30%"> <br> Sms Settings Microservice

This is a sms settings microservice from Pip.Services library. 
This microservice keeps settings of sms recipients.

The microservice currently supports the following deployment options:
* Deployment platforms: Standalone Process, Seneca
* External APIs: HTTP/REST, Seneca

This microservice has optional dependencies on the following microservices:
- [pip-services-activities-dart](https://github.com/pip-services-users/pip-services-activities-dart) - to log user activities
- [pip-services-msgtemplates-dart](https://github.com/pip-services-content/pip-services-msgtemplates-dart) - to get message templates
- [pip-services-sms-dart](https://github.com/pip-services-infrastructure/pip-services-sms-dart) - to send sms messages

<a name="links"></a> Quick Links:

* [Download Links](doc/Downloads.md)
* [Development Guide](doc/Development.md)
* [Configuration Guide](doc/Configuration.md)
* [Deployment Guide](doc/Deployment.md)
* Client SDKs
  - [Node.js SDK](https://github.com/pip-services-users/pip-clients-smssettings-node)
  - [Dart SDK](https://github.com/pip-services-users/pip-clients-smssettings-dart)
* Communication Protocols
  - [HTTP Version 1](doc/HttpProtocolV1.md)

## Contract

Logical contract of the microservice is presented below. For physical implementation (HTTP/REST),
please, refer to documentation of the specific protocol.

```dart
class SmsSettingsV1 implements IStringIdentifiable {
  /* Recipient information */
  String id;
  String name;
  String phone;
  String language;

  /* SmsSettings management */
  dynamic subscriptions;
  bool verified;
  String ver_code;
  DateTime ver_expire_time;

  /* Custom fields */
  dynamic custom_hdr;
  dynamic custom_dat;
}

abstract class ISmsSettingsV1 {
  Future<List<SmsSettingsV1>> getSettingsByIds(
      String correlationId, List<String> recipientIds);

  Future<SmsSettingsV1> getSettingsById(String correlationId, String recipientId);

  Future<SmsSettingsV1> getSettingsByPhoneSettings(String correlationId, String phone);

  Future<SmsSettingsV1> setSettings(String correlationId, SmsSettingsV1 settings);

  Future<SmsSettingsV1> setVerifiedSettings(String correlationId, SmsSettingsV1 settings);  

  Future<SmsSettingsV1> setRecipient(String correlationId, String recipientId, String name, String phone, String language);

  Future<SmsSettingsV1> setSubscriptions(String correlationId, String recipientId, dynamic subscriptions);

  Future<SmsSettingsV1> deleteSettingsById(String correlationId, String recipientId);

  Future resendVerification(String correlationId, String recipientId);

  Future verifySms(String correlationId, String recipientId, String code);
}
```

## Download

Right now the only way to get the microservice is to check it out directly from github repository
```bash
git clone git@github.com:pip-services-users/pip-services-smssettings-dart.git
```

Pip.Service team is working to implement packaging and make stable releases available for your 
as zip downloadable archieves.

## Run

Add **config.yaml** file to the root of the microservice folder and set configuration parameters.

Example of microservice configuration
```yaml
---
# Container descriptor
- descriptor: "pip-services:context-info:default:default:1.0"
  name: "pip-services-smssettings"
  description: "Sms Settings microservice for pip-services"

# Console logger
- descriptor: "pip-services:logger:console:default:1.0"
  level: "trace"

# Performance counters that posts values to log
- descriptor: "pip-services:counters:log:default:1.0"
  level: "trace"

{{#MEMORY_ENABLED}}
# In-memory persistence. Use only for testing!
- descriptor: "pip-services-smssettings:persistence:memory:default:1.0"
{{/MEMORY_ENABLED}}

{{#FILE_ENABLED}}
# File persistence. Use it for testing of for simple standalone deployments
- descriptor: "pip-services-smssettings:persistence:file:default:1.0"
  path: {{FILE_PATH}}{{^FILE_PATH}}"./data/smssettings.json"{{/FILE_PATH}}
{{/FILE_ENABLED}}

{{#MONGO_ENABLED}}
# MongoDB Persistence
- descriptor: "pip-services-smssettings:persistence:mongodb:default:1.0"
  collection: {{MONGO_COLLECTION}}{{^MONGO_COLLECTION}}smssettings{{/MONGO_COLLECTION}}
  connection:
    uri: {{{MONGO_SERVICE_URI}}}
    host: {{{MONGO_SERVICE_HOST}}}{{^MONGO_SERVICE_HOST}}localhost{{/MONGO_SERVICE_HOST}}
    port: {{MONGO_SERVICE_PORT}}{{^MONGO_SERVICE_PORT}}27017{{/MONGO_SERVICE_PORT}}
    database: {{MONGO_DB}}{{#^MONGO_DB}}app{{/^MONGO_DB}}
  credential:
    username: {{MONGO_USER}}
    password: {{MONGO_PASS}}
{{/MONGO_ENABLED}}

{{^MEMORY_ENABLED}}{{^FILE_ENABLED}}{{^MONGO_ENABLED}}
# Default in-memory persistence
- descriptor: "pip-services-smssettings:persistence:memory:default:1.0"
{{/MONGO_ENABLED}}{{/FILE_ENABLED}}{{/MEMORY_ENABLED}}

# Default controller
- descriptor: "pip-services-smssettings:controller:default:default:1.0"

# Common HTTP endpoint
- descriptor: "pip-services:endpoint:http:default:1.0"
  connection:
    protocol: "http"
    host: "0.0.0.0"
    port: 8080

# HTTP endpoint version 1.0
- descriptor: "pip-services-smssettings:service:http:default:1.0"

# Heartbeat service
- descriptor: "pip-services:heartbeat-service:http:default:1.0"

# Status service
- descriptor: "pip-services:status-service:http:default:1.0"
```
 
For more information on the microservice configuration see [Configuration Guide](doc/Configuration.md).

Start the microservice using the command:
```bash
dart ./bin/run.dart
```

## Use

The easiest way to work with the microservice is to use client SDK. 
The complete list of available client SDKs for different languages is listed in the [Quick Links](#links)

If you use dart, then get references to the required libraries:
- Pip.Services3.Commons : https://github.com/pip-services3-dart/pip-services3-commons-dart
- Pip.Services3.Rpc: 
https://github.com/pip-services3-dart/pip-services3-rpc-dart

Add **pip-services3-commons-dart**, **pip-services3-rpc-dart** and **pip-services_smssettings** packages
```dart
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import 'package:pip_services_smssettings/pip_services_smssettings.dart';

```

Define client configuration parameters that match the configuration of the microservice's external API
```dart
// Client configuration
var httpConfig = ConfigParams.fromTuples(
	"connection.protocol", "http",
	"connection.host", "localhost",
	"connection.port", 8080
);
```

Instantiate the client and open connection to the microservice
```dart
// Create the client instance
var client = SmsSettingsHttpClientV1(config);

// Configure the client
client.configure(httpConfig);

// Connect to the microservice
try{
  await client.open(null)
}catch() {
  // Error handling...
}       
// Work with the microservice
// ...
```

Now the client is ready to perform operations
```dart
// Create a new settings
final SETTINGS = SmsSettingsV1(
    id: '1',
    name: 'User 1',
    phone: '+1234567890',
    language: 'en',
    verified: false);

    // Create the settings
    try {
      var settings = await client.setSettings('123', SETTINGS);
      // Do something with the returned settings...
    } catch(err) {
      // Error handling...     
    }
```

```dart
// Get the settings
try {
var settings = await client.getSettingsByPhoneSettings(
    null,
    '+1234567890');
    // Do something with settings...

    } catch(err) { // Error handling}
```

```dart
// Verify an sms
try {
    settings1 = SETTINGS;
    settings1.ver_code = '123';  
    await controller.verifyPhone(null, '1', '123');

    var settings = await client.getSettingsByPhoneSettings(
    null,
    '+1234567890');
    // Do something with settings...

    } catch(err) { // Error handling}
``` 

## Acknowledgements

This microservice was created and currently maintained by
- **Sergey Seroukhov**
- **Nuzhnykh Egor**.
