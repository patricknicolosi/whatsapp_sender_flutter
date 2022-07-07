// ignore_for_file: depend_on_referenced_packages
library whatsapp_sender;

import 'dart:developer';
import 'package:flutter/material.dart' as material;
import 'package:puppeteer/puppeteer.dart';

class WhatsAppSender {
  static late Browser _browser;
  static late Page _page;

  static material.ValueNotifier<String> qrCode =
      material.ValueNotifier<String>("");
  static material.ValueNotifier<String> status =
      material.ValueNotifier<String>(WhatsAppSenderStatusMessage.initializing);

  static material.ValueNotifier<int> success = material.ValueNotifier<int>(0);
  static material.ValueNotifier<int> fails = material.ValueNotifier<int>(0);

  static Future sendTo(
      {required List<String> phones,
      required String message,
      String? savedSessionDir}) async {
    await _openWhatsAppWeb(savedSessionDir);
    await _readQrcode();
    try {
      await _waitChatScreen();
    } catch (e) {
      if (savedSessionDir == null || savedSessionDir.isEmpty) {
        status.value = WhatsAppSenderStatusMessage.qrCodeExpirated;
        await close();
        return;
      }
    }
    qrCode.value = "";
    for (int i = 0; i < phones.length; i++) {
      try {
        status.value = WhatsAppSenderStatusMessage.sending;
        await _page.goto(
            'https://web.whatsapp.com/send?phone=${phones[i]}&text=$message');
        var onDialog = _page.onDialog.listen((event) {
          event.accept();
        }, cancelOnError: true);
        onDialog.onDone(() {
          onDialog.cancel();
        });
        try {
          await _page.waitForSelector("progress",
              hidden: true, timeout: const Duration(milliseconds: 60000));
          await _page.waitForSelector(
              'div:nth-child(2) > button > span[data-icon="send"]',
              timeout: const Duration(milliseconds: 60000));
          await _page.keyboard.press(Key.enter);
          await Future.delayed(const Duration(milliseconds: 1000));
          success.value = success.value + 1;
        } catch (error) {
          success.value = fails.value + 1;
        }
      } catch (err) {
        fails.value = fails.value + 1;
      }
    }
    status.value = WhatsAppSenderStatusMessage.done;
    await close();
  }

  static Future close() async {
    await _browser.close();
  }

  static Future<void> _waitChatScreen() async {
    await _page.waitForSelector(
      '.zaKsw',
      timeout: const Duration(milliseconds: 60000),
    );
  }

  static Future<void> _readQrcode() async {
    //Wait code rendering
    await Future.delayed(const Duration(seconds: 3));

    //Read qrCode
    try {
      await _page
          .evaluate(
              '() => document.querySelector("div[data-ref]").getAttribute("data-ref")')
          .then((qrCodeData) {
        qrCode.value = qrCodeData;
      });
      status.value = WhatsAppSenderStatusMessage.scanQrCode;
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> _openWhatsAppWeb(String? savedSessionDir) async {
    _initializeStatusVariables();
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

  static _initializeStatusVariables() {
    success.value = 0;
    fails.value = 0;
    status.value = WhatsAppSenderStatusMessage.initializing;
    qrCode.value = "";
  }
}

class WhatsAppSenderStatusMessage {
  static String initializing = "initializing";
  static String scanQrCode = "scan qr code";
  static String sending = "sending";
  static String done = "done";
  static String qrCodeExpirated = "qr code expirated";
}
