abstract interface class LlmClient {
  String get name;
  Stream<String> ask(String prompt);
}
