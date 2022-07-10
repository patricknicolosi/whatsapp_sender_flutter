// ignore_for_file: depend_on_referenced_packages
library whatsapp_sender_flutter;

import 'dart:developer';
import 'package:flutter/material.dart' as material;
import 'package:puppeteer/puppeteer.dart';

class WhatsAppSenderFlutter {
  late Browser _browser;
  late Page _page;

  final material.ValueNotifier<String> _qrCode =
      material.ValueNotifier<String>("");
  final material.ValueNotifier<String> _status = material.ValueNotifier<String>(
      WhatsAppSenderFlutterStatusMessage.initializing);

  final material.ValueNotifier<int> _success = material.ValueNotifier<int>(0);
  final material.ValueNotifier<int> _fails = material.ValueNotifier<int>(0);

  Future send(
      {required List<String> phones,
      required String message,
      String? savedSessionDir}) async {
    _initializingStatusVariables();
    try {
      await _openWhatsAppWeb(savedSessionDir);
    } catch (e) {
      _status.value = WhatsAppSenderFlutterStatusMessage.errorOnLaunch;
      await close();
      return;
    }
    try {
      await _readQrCode();
    } catch (e) {
      log(e.toString());
    }
    try {
      await _waitChatScreen();
    } catch (e) {
      if (savedSessionDir == null || savedSessionDir.isEmpty) {
        _status.value = WhatsAppSenderFlutterStatusMessage.qrCodeExpirated;
        await close();
        return;
      }
    }
    _qrCode.value = "";
    for (int i = 0; i < phones.length; i++) {
      try {
        await _sendMessage(phones[i], message);
        _success.value = _success.value + 1;
      } catch (e) {
        _fails.value = _fails.value + 1;
      }
    }
    _status.value = WhatsAppSenderFlutterStatusMessage.done;
    await close();
    return;
  }

  Future close() async {
    try {
      await _browser.close();
    } catch (e) {
      log(e.toString());
    }
  }

  material.ValueNotifier<String> qrCode() {
    return _qrCode;
  }

  material.ValueNotifier<String> status() {
    return _status;
  }

  material.ValueNotifier<int> success() {
    return _success;
  }

  material.ValueNotifier<int> fails() {
    return _fails;
  }

  Future<void> _sendMessage(String phone, String message) async {
    _status.value = WhatsAppSenderFlutterStatusMessage.sending;
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

  Future<void> _readQrCode() async {
    await Future.delayed(const Duration(seconds: 3));
    await _page
        .evaluate(
            '() => document.querySelector("div[data-ref]").getAttribute("data-ref")')
        .then((qrCodeData) {
      _qrCode.value = qrCodeData;
      _status.value = WhatsAppSenderFlutterStatusMessage.scanQrCode;
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

  void _initializingStatusVariables() {
    _success.value = 0;
    _fails.value = 0;
    _qrCode.value = "";
    _status.value = WhatsAppSenderFlutterStatusMessage.initializing;
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
