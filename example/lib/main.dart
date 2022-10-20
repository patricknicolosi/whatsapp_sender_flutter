import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter_response.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter_response_message_values.dart';

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
  WhatsAppSenderFlutter whatsAppSenderFlutter = WhatsAppSenderFlutter();

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
                child: StreamBuilder<WhatsAppSenderFlutterResponse>(
                  stream: whatsAppSenderFlutter.send(
                    phones: [
                      "+391111111111",
                      "+391111111111",
                      "+391111111111",
                    ],
                    message: "Hello",
                  ),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Column(
                          children: [
                            Text(snapshot.data?.message ?? ""),
                            Text(snapshot.data?.qrCode ?? ""),
                            PrettyQr(
                                data: snapshot.data?.qrCode ?? "", size: 200),
                            Text((snapshot.data?.success ?? 0).toString()),
                          ],
                        )
                      : const SizedBox(),
                ),
              ),
            ),
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
