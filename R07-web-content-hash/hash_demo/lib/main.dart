import 'package:material_ui/material_ui.dart';

void main() => runApp(const DeployDemo());

class DeployDemo extends StatelessWidget {
  const DeployDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Text(
            'Build 2\nthe fix',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
