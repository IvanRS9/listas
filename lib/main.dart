import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:listas/modificar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tareas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Tareas> tareas = [];
  int? indextareas;
  TextEditingController tareaprincipal = TextEditingController();
  TextEditingController subtarea = TextEditingController();
  final Uuid uuid = Uuid();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void addTareas(String tareaTitulo) {
    setState(() {
      tareas.add(Tareas(tareaTitulo, [], uuid.v4()));

      tareaprincipal.clear();
    });

    saveTareas();
  }

  void saveTareas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tareasStr =
        jsonEncode(tareas.map((tarea) => tarea.toJson()).toList());

    prefs.setString('tareas', tareasStr);
  }

  void delTareas() {}

  void delSubTareas(int tareaIndex, int subtareaIndex) {
    setState(() {
      tareas[tareaIndex].subtareas.removeAt(subtareaIndex);
    });

    saveTareas();
  }

  void addSubTareas(int tareaIndex, String subtareaTitulo) {
    setState(() {
      tareas[tareaIndex].subtareas.add(subtareaTitulo);

      subtarea.clear();
    });

    saveTareas();
  }

  void editSubTareas(int tareaIndex, int subtareaIndex, String texto) {
    setState(() {
      tareas[tareaIndex].subtareas[subtareaIndex] = texto;
    });

    saveTareas();
  }

  void allTareas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tareasStr = prefs.getString('tareas') ?? '[]';

    List<dynamic> tareasJson = jsonDecode(tareasStr);

    setState(() {
      tareas = tareasJson.map((json) => Tareas.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tareaprincipal,
                        decoration: InputDecoration(hintText: 'Agregar tarea'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (tareaprincipal.text.isNotEmpty) {
                          addTareas(tareaprincipal.text);
                        }
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }

                  setState(() {
                    final Tareas tarea = tareas.removeAt(oldIndex);

                    tareas.insert(newIndex, tarea);
                  });

                  saveTareas();
                },
                children: [
                  for (int i = 0; i < tareas.length; i++)
                    Dismissible(
                      key: Key(tareas[i].id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        delTareas();
                      },
                      confirmDismiss: (direction) async {
                        return showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmación'),
                                content: Text('Eliminar tarea'),
                                actions: [
                                  TextButton(
                                      onPressed: () => {
                                            Navigator.of(context).pop(false),
                                          },
                                      child: Text('Cancelar')),
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.of(context).pop(true),
                                    },
                                    child: Text('Eliminar'),
                                  )
                                ],
                              );
                            });
                      },
                      background: Container(
                        color: Colors.red,
                      ),
                      child: ListTile(
                        title: Text(tareas[i].titulo),
                        onTap: () {
                          setState(() {
                            indextareas = i;
                          });

                          Navigator.of(context).pop();
                        },
                      ),
                    )
                ],
              ))
            ],
          ),
        ),
        body: indextareas == null
            ? Center(
                child: Text("Seleccionar una tarea"),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Expanded(
                                  child: TextField(
                                controller: subtarea,
                                decoration: InputDecoration(
                                    hintText: 'Agregar subtarea'),
                              )),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  if (subtarea.text.isNotEmpty) {
                                    addSubTareas(indextareas!, subtarea.text);
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }

                            setState(() {
                              final String tarea = tareas[indextareas!]
                                  .subtareas
                                  .removeAt(oldIndex);

                              tareas[indextareas!]
                                  .subtareas
                                  .insert(newIndex, tarea);
                            });

                            saveTareas();
                          },
                          children: [
                            for (int subi = 0;
                                subi < tareas[indextareas!].subtareas.length;
                                subi++)
                              Dismissible(
                                key: Key('${tareas[indextareas!].id}-$subi'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  delSubTareas(indextareas!, subi);
                                },
                                confirmDismiss: (direction) async {
                                  return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: Text("Confirmación"),
                                            content: Text('Eliminar Subtarea'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => {
                                                  Navigator.of(context)
                                                      .pop(false),
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => {
                                                  Navigator.of(context)
                                                      .pop(true)
                                                },
                                                child: Text('Eliminar'),
                                              )
                                            ]);
                                      });
                                },
                                background: Container(
                                  color: Colors.red,
                                ),
                                child: ListTile(
                                  title: Text(
                                      tareas[indextareas!].subtareas[subi]),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ModificarPage(
                                                      tareas[indextareas!]
                                                          .subtareas[subi])));

                                      if (result != null) {
                                        editSubTareas(
                                            indextareas!, subi, result);
                                      }
                                    },
                                  ),
                                ),
                              )
                          ],
                        ))
                      ],
                    ),
                  )
                ],
              )
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.add),
        // ),
        );
  }
}

class Tareas {
  String titulo;
  String id;
  List<String> subtareas;

  Tareas(this.titulo, this.subtareas, this.id);

  factory Tareas.fromJson(Map<String, dynamic> json) {
    return Tareas(json['titulo'], json['subtareas'], json['id']);
  }

  Map<String, dynamic> toJson() =>
      {'titulo': titulo, 'subtareas': subtareas, 'id': id};
}
