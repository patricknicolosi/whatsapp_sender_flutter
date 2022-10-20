import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter_response_message.dart';

class WhatsAppSenderFlutterResponse {
  String message = WhatsAppSenderFlutterResponseMessageValues.initializing;
  String? qrCode;
  int? success;
  int? fails;

  WhatsAppSenderFlutterResponse(
      {required this.message,
      required this.qrCode,
      required this.success,
      required this.fails});
}
