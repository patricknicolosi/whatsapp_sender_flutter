# WhatsApp Sender Flutter
[![pub package](https://img.shields.io/pub/v/whatsapp_sender_flutter.svg)](https://pub.dev/packages/whatsapp_sender_flutter)
[![pub points](https://img.shields.io/pub/points/whatsapp_sender_flutter?logo=dart)](https://pub.dev/packages/whatsapp_sender_flutter/score)
[![pub popularity](https://img.shields.io/pub/popularity/whatsapp_sender_flutter?logo=dart)](https://pub.dev/packages/whatsapp_sender_flutter/score)
[![pub likes](https://img.shields.io/pub/likes/whatsapp_sender_flutter?logo=dart)](https://pub.dev/packages/whatsapp_sender_flutter/score)

WhatsApp Sender Flutter is an unofficial API for Flutter to send bulk messages in Whatsapp. It's not recommended using it in your company or for marketing purpose.

<a href="https://www.buymeacoffee.com/patrickNicT" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Book" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

## Getting Started
In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  whatsapp_sender_flutter: latest
```

Import it:

```dart
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';
```

## Configuration
For the first usage, wait for the automatic download of the ```.local-chromium``` folder in your project root. Without this folder the package will not work,this is because this package is based on [puppeteer](https://github.com/xvrh/puppeteer-dart).
## Basic usage

Thanks to [rohitsangwan01](https://github.com/rohitsangwan01) for reference!

The process for sending messages is like for WhatsApp Web:

1. Scan the qr code
2. Start the sending


### Send text message
After you have scanned the code, you can start the sending campaign.

**All phones must contain the international prefix!**

```dart
   ...
   await WhatsAppSenderFlutter.send(
         phones: [ "391111111", "391111111", "391111111"],
         message: "Hello",
   );
```

### Send file message
After you have scanned the code, you can start the sending campaign.

**All phones must contain the international prefix!**

```dart
   await WhatsAppSenderFlutter.send(
         phones: [ "391111111", "391111111", "391111111"],
         message: "Hello",
         file: File("path-to-file.pdf"),
   );
```

### Listen changes

New functions for listen changes:

1. ```onEvent(WhatsAppSenderFlutterStatus status)```, usethis function to listen the sending status
2. ```onQrCode(String qrCode)```, use this function to intercept the qrCode 
3. ```onSending(WhatsAppSenderFlutterCounter counter)```, use this function to count the number of successful or unsuccessful submissions. 
4. ```onError(WhatsAppSenderFlutterErrorMessage errorMessage)```, use this feature to catch errors while sending

```dart
   ...
   await WhatsAppSenderFlutter.send(
        phones: [ "391111111", "391111111", "391111111"],
        message: "Hello",
        file: File("path-to-file.pdf"),
        onEvent: (WhatsAppSenderFlutterStatus status) {
          print(status);
        },
        onQrCode: (String qrCode) {
          print(qrCode);
        },
        onSending: (WhatsAppSenderFlutterCounter counter) {
          print(counter.success.toString());
          print(counter.fails.toString());
        },
        onError: (WhatsAppSenderFlutterErrorMessage errorMessage) {
          print(errorMessage);
        },
   );
```
To know in detail the possible states of ```WhatsAppSenderFlutterStatus```, ```WhatsAppSenderFlutterCounter```, ```WhatsAppSenderFlutterErrorMessage``` read documentation

### Save your session

```dart
   WhatsAppSenderFlutter whatsAppSenderFlutter = WhatsAppSenderFlutter();
   ...
   await whatsAppSenderFlutter.send(
         phones: [ "391111111", "391111111", "391111111"],
         message: "Hello",
         savedSessionDir: "./userData"
   );
```

To save the session you must indicate a folder name in ``` savedSessionDir```.

**If you save the session you will no longer have to scan the qr code !**

Do not indicate ``` savedSessionDir``` if you want to be asked to scan the qr code at each sending.

## To Do
- Send text message ✔️
- Multi session support ✔️
- Send files ✔️


## License
[MIT](https://choosealicense.com/licenses/mit/)

