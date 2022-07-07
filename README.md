# WhatsApp Sender

![af](https://user-images.githubusercontent.com/23001470/177776109-a9eb8f52-6b4e-4c21-83fe-a70f59b694a3.png)

WhatsApp Sender is an unofficial API to send bulk messages in Whatsapp. It's not recommended using it in your company or for marketing purpose.

<a href="https://www.buymeacoffee.com/patrickNicT" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Book" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

## Getting Started
In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  whatsapp_sender_flutter: ^0.0.1
```

Import it:

```dart
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';
```

## Configuration
For the first usage, wait for the automatic download of the ```.local-chromium``` folder in your project root. Without this folder the package will not work,this is because this package is based on [puppeteer](https://github.com/xvrh/puppeteer-dart).

**Problem** If the automatic download doesn't work you can copy the folder, which you can download from [here](https://drive.google.com/drive/folders/1oA9EO6pYiAlH6RTn_-fb6epwQ6Lm9y9a?usp=sharing), manually in your project root.

## Basic usage

The process for sending messages is like for WhatsApp Web:

1. Scan the qr code
2. Start the sending

### Render qrcode to scan
For render qrcode to scan use package like [pretty_qr_code](https://pub.dev/packages/pretty_qr_code).


```dart
   import 'package:pretty_qr_code/pretty_qr_code.dart';
   ...
   ValueListenableBuilder<String>(
     valueListenable: WhatsAppSender.qrCode,
     builder: (context, value, widget) {
              return value.isEmpty 
                     ? const SizedBox()
                      : PrettyQr(
                          size: 300,
                          data: value,
                          roundEdges: true,
                        );
                      },
  ),
```


The static variable  ```WhatsAppSender.qrCode``` is a ```ValueNotifier```. You can use ```ValueListenableBuilder``` to listen changes.



### Start the sending 
After you have scanned the code, you can start the sending campaign.

**All phones must contain the international prefix!**


```dart
   await WhatsAppSender.sendTo(
         phones: [ "+391111111", "+391111111", "+391111111"],
         message: "Hello",
   );
```

## Advanced usage
### Listen sending status
```dart
   ValueListenableBuilder<String>(
     valueListenable: WhatsAppSender.status,
     builder: (context, value, widget) {
                return Text(value);
              },
  ),
```


The static variable  ```WhatsAppSender.status``` is a ```ValueNotifier```. You can use ```ValueListenableBuilder``` to listen changes.

Possible states of ```WhatsAppSender.status``` are:
- ``` WhatsAppSenderStatusMessage.initialize``` during WhatsApp initialization 
- ``` WhatsAppSenderStatusMessage.scanQrCode``` during qr code scanning
- ``` WhatsAppSenderStatusMessage.sending``` during sending
- ``` WhatsAppSenderStatusMessage.done``` if seding is end
- ``` WhatsAppSenderStatusMessage.qrCodeExpirated``` if qrcode to scan is expirated


### Listen the number of success sendings
```dart
   ValueListenableBuilder<String>(
     valueListenable: WhatsAppSender.success,
     builder: (context, value, widget) {
                return Text(value.toString());
              },
  ),
```

The static variable  ```WhatsAppSender.success``` is a ```ValueNotifier```. You can use ```ValueListenableBuilder``` to listen changes.


### Listen the number of fails sendings
```dart
   ValueListenableBuilder<String>(
     valueListenable: WhatsAppSender.fails,
     builder: (context, value, widget) {
                return Text(value.toString());
              },
  ),
```

The static variable  ```WhatsAppSender.fails``` is a ```ValueNotifier```. You can use ```ValueListenableBuilder``` to listen changes.

### Save your session

```dart
   await WhatsAppSender.sendTo(
         phones: [ "+391111111", "+391111111", "+391111111"],
         message: "Hello",
         savedSessionDir: "./userData"
   );
```

To save the session you must indicate a folder name in ``` savedSessionDir```.

**If you save the session you will no longer have to scan the qr code !**

Do not indicate ``` savedSessionDir``` if you want to be asked to scan the qr code at each sending.



## Example
```dart
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:whatsapp_sender/whatsapp_sender.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.send),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: WhatsAppSender.qrCode,
                      builder: (context, value, widget) {
                        return value.isEmpty
                            ? const SizedBox()
                            : PrettyQr(
                                size: 300,
                                data: value,
                                roundEdges: true,
                              );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: WhatsAppSender.status,
                      builder: (context, value, widget) {
                        return Text(value);
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: WhatsAppSender.success,
                      builder: (context, value, widget) {
                        return Text("$value success");
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: WhatsAppSender.fails,
                      builder: (context, value, widget) {
                        return Text("$value fails");
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
          await WhatsAppSender.sendTo(
            phones: [
              "+391111111111",
              "+391111111111",
              "+391111111111",
            ],
            message: "Hello",
          );
        },
      ),
      appBar: AppBar(
        title: const Text("WhatsApp sender"),
      ),
      body: const Center(
        child: Text("Press send button to start the sending"),
      ),
    );
  }
}

```
## To Do
- Send text message ✔️
- Send image (*coming soon!*)


## License
[MIT](https://choosealicense.com/licenses/mit/)

