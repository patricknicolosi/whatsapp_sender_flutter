# WhatsApp Sender

WhatsApp Sender is an unofficial API to send bulk messages in whatsapp. It's not recommended using it in your company or for marketing purpose.


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
1. ``` WhatsAppSenderStatusMessage.initialize``` during WhatsApp initialization 
2. ``` WhatsAppSenderStatusMessage.scanQrCode``` during qr code scanning
3. ``` WhatsAppSenderStatusMessage.sending``` during sending
4. ``` WhatsAppSenderStatusMessage.done``` if seding is end
5. ``` WhatsAppSenderStatusMessage.qrCodeExpirated``` if qrcode to scan is expirated


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
