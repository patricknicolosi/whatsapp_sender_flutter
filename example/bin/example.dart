import 'dart:io';

import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';

void main(List<String> arguments) async {
  await WhatsAppSenderFlutter.send(
    phones: ["3912345"],
    message: "Test",
    file: File("path-to-file.pdf"),
    savedSessionDir: "0",
    onEvent: (WhatsAppSenderFlutterStatus status) {
      print(status);
    },
    onQrCode: (String qrCode) {
      print(qrCode);
    },
    onSending: (WhatsAppSenderFlutterCounter counter) {
      print(counter.toString());
    },
    onError: (WhatsAppSenderFlutterErrorMessage errorMessage) {
      print(errorMessage);
    },
  );
}
