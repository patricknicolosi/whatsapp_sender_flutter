import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter.dart';

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
                child: Column(
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: whatsAppSenderFlutter.qrCode,
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
                      valueListenable: whatsAppSenderFlutter.status,
                      builder: (context, value, widget) {
                        return Text(value);
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: whatsAppSenderFlutter.success,
                      builder: (context, value, widget) {
                        return Text("$value success");
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: whatsAppSenderFlutter.fails,
                      builder: (context, value, widget) {
                        return Text("$value fails");
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
          whatsAppSenderFlutter.fails.value = 0;
          await whatsAppSenderFlutter.sendTo(
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
