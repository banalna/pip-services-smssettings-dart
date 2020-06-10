# HTTP REST Protocol (version 1) <br> Sms Settings Microservice

Sms settings microservice implements a REST compatible API, that can be accessed on configured port.
All input and output data is serialized in JSON format. Errors are returned in [standard format]().

* [SmsSettingsV1 class](#class1)
* [POST /sms_settings/get_settings_by_ud](#operation1)
* [POST /sms_settings/get_settings_by_phone](#operation2)
* [POST /sms_settings/set_settings](#operation3)
* [POST /sms_settings/set_recipient](#operation4)
* [POST /sms_settings/set_subscriptions](#operation5)
* [POST /sms_settings/delete_settings_by_id](#operation6)
* [POST /sms_settings/resend_verification](#operation7)
* [POST /sms_settings/verify_phone](#operation8)

## Data types

### <a name="class1"></a> SmsSettingsV1 class

Represents a user sms settings with his ID, primary phone and key settings.

**Properties:**
- id: string - unique user id
- name: string - user full name
- phone: string - primary user phone
- language: string - user preferred language
- verified: boolean - true if sms was verified
- ver_code: - sms verification code that was sent in sms message to the user
- ver\_expire\_time: Date - expiration time for sms verification code
- subscriptions: Object - subscriptions to enable or disable certain types of sms messages
- custom_hdr: Object - custom data summary that is always returned (in list and details)
- custom_dat: Object - custom data details that is returned only when a single object is returned (details)

## Operations

### <a name="operation1"></a> Method: 'POST', route '/sms\_settings/get\_settings\_by_id'

Retrieves sms settings by recipient unique id. 

**Request body:** 
- recipient_id: string - unique receipient id

**Response body:**
Retrieved SmsSettingsV1 object or error

### <a name="operation2"></a> Method: 'POST', route '/sms\_settings/get\_settings\_by_sms'

Retrieves sms settings by recipient phone. 

**Request body:** 
- phone: string - phone number

**Response body:**
Retrieved SmsSettingsV1 object or error

### <a name="operation3"></a> Method: 'POST', route '/sms\_settings/set_settings'

Sets recipient sms settings

**Request body:** 
- settings: SmsSettingsV1 -  sms settings to be set

**Response body:**
Set SmsSettingsV1 object or error

### <a name="operation4"></a> Method: 'POST', route '/sms\_settings/set_recipient'

Sets recipient information into sms settings.
If some properties are not set, they keep their old values.

**Request body:** 
- recipient_id: string - recipient unique id
- name: string - recipient full name
- sms: string - recipient sms address
- language: string - recipient preferred language

**Response body:**
Set SmsSettingsV1 object or error

### <a name="operation5"></a> Method: 'POST', route '/sms\_settings/set_subscriptions'

Sets subscriptions to specific sms types.

**Request body:** 
- recipient_id: string - recipient unique id
- subscriptions: any - subscriptions hashmap where sms types are enabled or disabled

**Response body:**
Set SmsSettingsV1 object or error

### <a name="operation6"></a> Method: 'POST', route '/sms\_settings/delete\_settings\_by_id'

Deletes sms settings from the system (use it carefully!)

**Request body:** 
- recipient_id: string - recipient unique id

**Response body:**
Error or null for success

### <a name="operation6"></a> Method: 'POST', route '/sms\_settings/resend\_verification'

Generates a new sms verification code and sends it to recipient via sms message.
Initial verification code is send in welcome message during user registration.

**Request body:** 
- recipient_id: string - recipient unique id

**Response body:**
Error or null for success

### <a name="operation7"></a> Method: 'POST', route '/sms\_settings/verify_phone'

Confirms (verifies) primary phone number using verification code.

**Request body:** 
- recipient_id: string - recipient unique id
- code: string - password recovery code

**Response body:**
Error or null for success
