import 'package:flutter/material.dart';

class ModificarPage extends StatefulWidget {
  final String subTask;

  ModificarPage(this.subTask);

  @override
  _ModificarPageState createState() => _ModificarPageState();
}

class _ModificarPageState extends State<ModificarPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.subTask);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Subtarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Subtarea',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
