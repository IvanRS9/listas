import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'modificar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listado de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color.fromRGBO(52, 73, 94, 1)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Tareas> tareasprincipal = [];
  int? tareai;
  final TextEditingController tareacontroller = TextEditingController();
  final TextEditingController subtareacontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    tareasAll();
  }

  void tareasAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tasksString = prefs.getString('tareasprincipal') ?? '[]';

    List<dynamic> tasksJson = jsonDecode(tasksString);

    setState(() {
      tareasprincipal = tasksJson.map((json) => Tareas.fromJson(json)).toList();
    });
  }

  void tareasSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String tareasStr =
        jsonEncode(tareasprincipal.map((task) => task.toJson()).toList());

    prefs.setString('tareasprincipal', tareasStr);
  }

  void tareasDel(int i) {
    setState(() {
      tareasprincipal.removeAt(i);

      if (tareai == i) {
        tareai = null;
      } else if (tareai != null && tareai! > i) {
        tareai = tareai! - 1;
      }
    });

    tareasSave();
  }

  void subtareasDel(int tareaindex, int subtareaindex) {
    setState(() {
      tareasprincipal[tareaindex].subtarea.removeAt(subtareaindex);
    });

    tareasSave();
  }

  void tareasAdd(String tareatitulo) {
    setState(() {
      tareasprincipal.add(Tareas(tareatitulo, []));

      tareacontroller.clear();
    });

    tareasSave();
  }

  void subtareasAdd(int teareaindex, String subtareaTitulo) {
    setState(() {
      tareasprincipal[teareaindex].subtarea.add(subtareaTitulo);

      subtareacontroller.clear();
    });

    tareasSave();
  }

  void subtareaEdit(int tareaindex, int subtareaindeex, String newText) {
    setState(() {
      tareasprincipal[tareaindex].subtarea[subtareaindeex] = newText;
    });

    tareasSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tareas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(39, 55, 70, 1),
      ),
      drawer: Drawer(
        backgroundColor: Color.fromRGBO(39, 55, 70, 1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tareacontroller,
                      decoration: const InputDecoration(
                        hintText: 'Agregar tarea',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      if (tareacontroller.text.isNotEmpty) {
                        tareasAdd(tareacontroller.text);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView(
                onReorder: (tareaindexOLD, tareaindexNEW) {
                  if (tareaindexNEW > tareaindexOLD) {
                    tareaindexNEW -= 1;
                  }
                  setState(() {
                    final Tareas t = tareasprincipal.removeAt(tareaindexOLD);

                    tareasprincipal.insert(tareaindexNEW, t);
                  });

                  tareasSave();
                },
                children: [
                  for (int i = 0; i < tareasprincipal.length; i++)
                    Dismissible(
                      key: Key('tarea-$i'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        tareasDel(i);
                      },
                      confirmDismiss: (direction) async {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmación'),
                              content: const Text('Eliminar tarea'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(
                          tareasprincipal[i].titulo,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final tareaedit = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ModificarPage(
                                        texto: tareasprincipal[i].titulo)));

                            if (tareaedit != null) {
                              setState(() {
                                tareasprincipal[i].titulo = tareaedit;
                              });

                              tareasSave();
                            }
                          },
                        ),
                        onTap: () {
                          setState(() {
                            tareai = i;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: tareai == null
          ? Center(
              child: Text(
              'Selecciona una tarea del menú',
              style: TextStyle(color: Colors.white),
            ))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: subtareacontroller,
                          decoration: const InputDecoration(
                            hintText: 'Agregar subtarea',
                            hintStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (subtareacontroller.text.isNotEmpty) {
                            subtareasAdd(tareai!, subtareacontroller.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (i, newi) {
                      if (newi > i) {
                        newi -= 1;
                      }
                      setState(() {
                        final String item =
                            tareasprincipal[tareai!].subtarea.removeAt(i);
                        tareasprincipal[tareai!].subtarea.insert(newi, item);
                      });

                      tareasSave();
                    },
                    children: [
                      for (int subti = 0;
                          subti < tareasprincipal[tareai!].subtarea.length;
                          subti++)
                        Dismissible(
                          key: Key('subtask-$tareai-$subti'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            subtareasDel(tareai!, subti);
                          },
                          confirmDismiss: (direction) async {
                            return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmación'),
                                  content: const Text('Eliminar subtarea'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          background: Container(color: Colors.red),
                          child: ListTile(
                            title: Text(
                              tareasprincipal[tareai!].subtarea[subti],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final edit = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModificarPage(
                                      texto: tareasprincipal[tareai!]
                                          .subtarea[subti],
                                    ),
                                  ),
                                );
                                if (edit != null) {
                                  subtareaEdit(tareai!, subti, edit);
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class Tareas {
  String titulo;
  List<String> subtarea;

  Tareas(this.titulo, this.subtarea);

  factory Tareas.fromJson(Map<String, dynamic> json) {
    return Tareas(
      json['titulo'],
      List<String>.from(json['subtarea']),
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'subtarea': subtarea,
      };
}
