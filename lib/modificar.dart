import 'package:flutter/material.dart';

class ModificarPage extends StatefulWidget {
  final String texto;

  ModificarPage({required this.texto});

  @override
  _ModificarPageState createState() => _ModificarPageState();
}

class _ModificarPageState extends State<ModificarPage> {
  late TextEditingController modificarcontroller;

  @override
  void initState() {
    super.initState();
    modificarcontroller = TextEditingController(text: widget.texto);
  }

  @override
  void dispose() {
    modificarcontroller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(modificarcontroller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.texto),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: modificarcontroller,
              decoration: InputDecoration(
                labelText: 'Modificar ' + widget.texto,
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
