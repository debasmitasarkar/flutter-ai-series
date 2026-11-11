import 'package:flutter/material.dart';

import 'answer_screen.dart';
import 'fake_stream.dart';

void main() => runApp(
      MaterialApp(home: AnswerScreen(chunks: fakeStructuredReply())),
    );
