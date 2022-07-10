// ignore_for_file: depend_on_referenced_packages
library whatsapp_sender_flutter;

import 'dart:developer';
import 'package:flutter/material.dart' as material;
import 'package:puppeteer/puppeteer.dart';

class WhatsAppSenderFlutter {
  late Browser _browser;
  late Page _page;

  final material.ValueNotifier<String> qrCode =
      material.ValueNotifier<String>("");
  final material.ValueNotifier<String> status = material.ValueNotifier<String>(
      WhatsAppSenderFlutterStatusMessage.initializing);

  final material.ValueNotifier<int> success = material.ValueNotifier<int>(0);
  final material.ValueNotifier<int> fails = material.ValueNotifier<int>(0);

  Future send(
      {required List<String> phones,
      required String message,
      String? savedSessionDir}) async {
    await _openWhatsAppWeb(savedSessionDir);
    await _readQrcode();
    await _waitChatScreen(savedSessionDir);
    for (int i = 0; i < phones.length; i++) {
      await _sendMessage(phones[i], message);
    }
    status.value = WhatsAppSenderFlutterStatusMessage.done;
    await close();
    _initializingStatusVariables();
  }

  Future close() async {
    try {
      await _browser.close();
    } catch (e) {
      log(e.toString());
    }
  }

  void _initializingStatusVariables() {
    success.value = 0;
    fails.value = 0;
    qrCode.value = "";
    status.value = WhatsAppSenderFlutterStatusMessage.initializing;
  }

  Future<void> _sendMessage(String phone, String message) async {
    try {
      status.value = WhatsAppSenderFlutterStatusMessage.sending;
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
      success.value = success.value + 1;
    } catch (e) {
      fails.value = fails.value + 1;
    }
  }

  Future<void> _waitChatScreen(String? savedSessionDir) async {
    try {
      qrCode.value = "";
      await _page.waitForSelector(
        '.zaKsw',
        timeout: const Duration(milliseconds: 60000),
      );
    } catch (e) {
      if (savedSessionDir == null || savedSessionDir.isEmpty) {
        status.value = WhatsAppSenderFlutterStatusMessage.qrCodeExpirated;
        await close();
      } else {
        await close();
      }
      return;
    }
  }

  Future<void> _readQrcode() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      await _page
          .evaluate(
              '() => document.querySelector("div[data-ref]").getAttribute("data-ref")')
          .then((qrCodeData) {
        qrCode.value = qrCodeData;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _openWhatsAppWeb(String? savedSessionDir) async {
    try {
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
    } catch (e) {
      status.value = WhatsAppSenderFlutterStatusMessage.errorOnLaunch;
    }
  }
}

class WhatsAppSenderFlutterStatusMessage {
  static const String initializing = "initializing";
  static const String errorOnLaunch = "error on launch";
  static const String scanQrCode = "scan qr code";
  static const String sending = "sending";
  static const String done = "done";
  static const String qrCodeExpirated = "qr code expirated";
}
