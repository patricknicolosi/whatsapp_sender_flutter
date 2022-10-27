class WhatsAppSenderFlutterCounter {
  int success = 0;
  int fails = 0;

  WhatsAppSenderFlutterCounter(this.success, this.fails);

  @override
  String toString() {
    return "SUCCESS: $success, FAILS:$fails";
  }
}
