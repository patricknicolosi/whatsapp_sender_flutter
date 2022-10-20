// ignore_for_file: depend_on_referenced_packages
library whatsapp_sender_flutter;

import 'dart:async';
import 'dart:developer';
import 'package:puppeteer/puppeteer.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter_response.dart';
import 'package:whatsapp_sender_flutter/whatsapp_sender_flutter_response_message.dart';

class WhatsAppSenderFlutter {
  late Browser _browser;
  late Page _page;

  Stream<WhatsAppSenderFlutterResponse> send(
      {required List<String> phones,
      required String message,
      String? savedSessionDir}) {
    late StreamController<WhatsAppSenderFlutterResponse> controller;

    controller = StreamController<WhatsAppSenderFlutterResponse>(
      onListen: () async {
        await _send(controller: controller, phones: phones, message: message);
      },
      onCancel: () async {
        await _close();
      },
    );

    return controller.stream;
  }

  _send(
      {required StreamController<WhatsAppSenderFlutterResponse> controller,
      required List<String> phones,
      required String message,
      String? savedSessionDir}) async {
    try {
      await _openWhatsAppWeb(savedSessionDir);
      controller.add(
        WhatsAppSenderFlutterResponse(
            message: WhatsAppSenderFlutterResponseMessageValues.initializing,
            qrCode: null,
            success: null,
            fails: null),
      );
      await controller.close();
    } catch (e) {
      controller.add(WhatsAppSenderFlutterResponse(
          message: WhatsAppSenderFlutterResponseMessageValues.errorOnLaunch,
          qrCode: null,
          success: null,
          fails: null));
      await controller.close();
      await _close();
      return;
    }
    try {
      await _readQrCode(controller);
    } catch (e) {
      log(e.toString());
    }
    try {
      await _waitChatScreen();
    } catch (e) {
      if (savedSessionDir == null || savedSessionDir.isEmpty) {
        controller.add(
          WhatsAppSenderFlutterResponse(
              message:
                  WhatsAppSenderFlutterResponseMessageValues.qrCodeExpirated,
              qrCode: null,
              success: null,
              fails: null),
        );
        await controller.close();
        await _close();
        return;
      }
    }
    controller.add(
      WhatsAppSenderFlutterResponse(
          message: WhatsAppSenderFlutterResponseMessageValues.sending,
          qrCode: null,
          success: 0,
          fails: 0),
    );
    await controller.close();
    int fails = 0;
    int success = 0;
    for (int i = 0; i < phones.length; i++) {
      try {
        await _sendMessage(phones[i], message, controller);
        success = success + 1;
        controller.add(
          WhatsAppSenderFlutterResponse(
              message: WhatsAppSenderFlutterResponseMessageValues.sending,
              qrCode: null,
              success: success,
              fails: fails),
        );
        await controller.close();
      } catch (e) {
        controller.add(
          WhatsAppSenderFlutterResponse(
              message: WhatsAppSenderFlutterResponseMessageValues.sending,
              qrCode: null,
              success: success,
              fails: fails),
        );
        await controller.close();
      }
    }
    await _close();
  }

  Future _close() async {
    try {
      await _browser.close();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _sendMessage(String phone, String message,
      StreamController<WhatsAppSenderFlutterResponse> controller) async {
    await controller.close();
    await _page
        .goto('https://web.whatsapp.com/send?phone=$phone&text=$message');
    var onDialog = _page.onDialog.listen((event) {
      event.accept();
    }, cancelOnError: true);
    onDialog.onDone(() {
      onDialog.cancel();
    });
    await _page.waitForSelector("progress",
        hidden: true, timeout: const Duration(milliseconds: 60000));
    await _page.waitForSelector(
        'div:nth-child(2) > button > span[data-icon="send"]',
        timeout: const Duration(milliseconds: 60000));
    await _page.keyboard.press(Key.enter);
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  Future<void> _waitChatScreen() async {
    await _page.waitForSelector(
      '.zaKsw',
      timeout: const Duration(milliseconds: 60000),
    );
  }

  Future<void> _readQrCode(
      StreamController<WhatsAppSenderFlutterResponse> controller) async {
    await Future.delayed(const Duration(seconds: 3));
    await _page
        .evaluate(
            '() => document.querySelector("div[data-ref]").getAttribute("data-ref")')
        .then((qrCodeData) async {
      controller.add(WhatsAppSenderFlutterResponse(
          message: WhatsAppSenderFlutterResponseMessageValues.scanQrCode,
          qrCode: qrCodeData,
          success: null,
          fails: null));
      await controller.close();
    });
  }

  Future<void> _openWhatsAppWeb(String? savedSessionDir) async {
    _browser = await puppeteer.launch(
      headless: true,
      noSandboxFlag: true,
      args: ['--disable-setuid-sandbox'],
      userDataDir: savedSessionDir,
    );
    _page = await _browser.newPage();
    const userAgent =
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.39 Safari/537.36';
    await _page.setUserAgent(userAgent);
    await _page.goto('http://web.whatsapp.com');
  }
}
