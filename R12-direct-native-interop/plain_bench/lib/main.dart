import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

const _channel = MethodChannel('bench');

void main() => runApp(
  MaterialApp(
    home: Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _channel.invokeMethod<Object>('uptime'),
          builder: (_, s) => Text('${s.data}'),
        ),
      ),
    ),
  ),
);
