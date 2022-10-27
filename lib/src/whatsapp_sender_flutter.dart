// ignore_for_file: depend_on_referenced_packages
library whatsapp_sender_flutter;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mime_type/mime_type.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:whatsapp_sender_flutter/src/model/whatsapp_sender_flutter_counter.dart';
import 'package:whatsapp_sender_flutter/src/model/whatsapp_sender_flutter_error_message.dart';
import 'package:whatsapp_sender_flutter/src/model/whatsapp_sender_flutter_status.dart';
import 'package:whatsapp_sender_flutter/src/wpp/wpp_js_content.dart';

class WhatsAppSenderFlutter {
  static late Browser _browser;
  static late Page _page;

  static Future send({
    required List<String> phones,
    required String message,
    File? file,
    String? savedSessionDir,
    Function(String)? onQrCode,
    Function(WhatsAppSenderFlutterErrorMessage)? onError,
    Function(WhatsAppSenderFlutterStatus)? onEvent,
    Function(WhatsAppSenderFlutterCounter)? onSending,
    bool? headless,
  }) async {
    await _send(
        phones: phones,
        message: message,
        savedSessionDir: savedSessionDir,
        file: file,
        onQrCode: onQrCode,
        onError: onError,
        onEvent: onEvent,
        onSending: onSending,
        headless: headless);
  }

  static _send({
    required List<String> phones,
    required String message,
    String? savedSessionDir,
    File? file,
    Function(String)? onQrCode,
    Function(WhatsAppSenderFlutterErrorMessage)? onError,
    Function(WhatsAppSenderFlutterStatus)? onEvent,
    Function(WhatsAppSenderFlutterCounter)? onSending,
    bool? headless,
  }) async {
    try {
      onEvent?.call(WhatsAppSenderFlutterStatus.initializing);
      await _openWhatsAppWeb(savedSessionDir, headless);
    } catch (e) {
      onError?.call(WhatsAppSenderFlutterErrorMessage.errorOnLaunch);
      await _close();
      return;
    }
    try {
      await _readQrCode(onQrCode);
      onEvent?.call(WhatsAppSenderFlutterStatus.scanQrCode);
    } catch (e) {
      onError?.call(WhatsAppSenderFlutterErrorMessage.qrCodeExpirated);
      log(e.toString());
    }
    try {
      await _waitChatScreen();
    } catch (e) {
      if (savedSessionDir == null || savedSessionDir.isEmpty) {
        onError?.call(WhatsAppSenderFlutterErrorMessage.unknown);
        await _close();
        return;
      }
    }
    onEvent?.call(WhatsAppSenderFlutterStatus.sending);
    WhatsAppSenderFlutterCounter whatsAppSenderFlutterStatus =
        WhatsAppSenderFlutterCounter(0, 0);
    for (int i = 0; i < phones.length; i++) {
      try {
        await _sendMessage(phones[i], message, file);
        whatsAppSenderFlutterStatus.success =
            whatsAppSenderFlutterStatus.success + 1;
        onSending?.call(whatsAppSenderFlutterStatus);
      } catch (e) {
        whatsAppSenderFlutterStatus.fails =
            whatsAppSenderFlutterStatus.fails + 1;
        onSending?.call(whatsAppSenderFlutterStatus);
        onError?.call(WhatsAppSenderFlutterErrorMessage.errorOnSend);
      }
    }
    await _close();
  }

  static Future _close() async {
    try {
      await _browser.close();
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> _sendMessage(
    String phone,
    String message,
    File? file,
  ) async {
    String content = wppJsContent.trim();
    await _page.addScriptTag(content: content, type: "module");
    phone = "$phone@c.us";
    if (file != null && file.existsSync()) {
      String base64File = base64Encode(file.readAsBytesSync());
      String? mimeType = mime(file.path);
      String fileData = "data:$mimeType;base64,$base64File";
      await _page
          .evaluate('''(phone,imgData,caption) => WPP.chat.sendFileMessage(
        phone,imgData,
        {
          type: 'image',
          caption: caption
        });''', args: [phone, fileData, message]);
    } else {
      await _page.evaluate(
        '''() => WPP.chat.sendTextMessage("$phone", "$message");''',
      );
    }
  }

  static Future<void> _waitChatScreen() async {
    await _page.waitForSelector(
      '.zaKsw',
      timeout: const Duration(milliseconds: 60000),
    );
  }

  static Future<void> _readQrCode(Function(String)? onQrCode) async {
    await Future.delayed(const Duration(seconds: 3));
    await _page
        .evaluate(
            '() => document.querySelector("div[data-ref]").getAttribute("data-ref")')
        .then((qrCodeData) async {
      onQrCode?.call(qrCodeData);
    });
  }

  static Future<void> _openWhatsAppWeb(
      String? savedSessionDir, bool? headless) async {
    _browser = await puppeteer.launch(
      headless: headless,
      noSandboxFlag: true,
      args: ['--start-maximized', '--disable-setuid-sandbox'],
      userDataDir: savedSessionDir,
    );
    _page = await _browser.newPage();
    const userAgent =
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.39 Safari/537.36';
    await _page.setUserAgent(userAgent);
    await _page.goto('http://web.whatsapp.com');
  }
}
