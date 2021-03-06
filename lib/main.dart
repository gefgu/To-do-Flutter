import 'package:flutter/material.dart';
import 'package:tododark/database_helpers.dart';

void main() => runApp(MyApp());

const List<Color> colorsScheme = [
  Color(0xFF90AFC5),
  Color(0xFF336887),
  Color(0xFF2A3132),
  Color(0xFF2C7873),
  Color(0xFF763626)
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Knight',
      theme: ThemeData(
        primaryColor: colorsScheme[1],
        brightness: Brightness.dark,
        accentColor: colorsScheme[1],
      ),
      home: new TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> todoList;

  Future<List<Todo>> getTodosFromDatabase() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    todoList = await helper.getAllTodo();
    return helper.getAllTodo();
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder futureLoader = FutureBuilder(
      future: getTodosFromDatabase(),
      // ignore: missing_return
      builder: (context, snapshot) {
        Widget widgetReturn;
        if (snapshot.hasData) {
          widgetReturn = ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: todoList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < todoList.length) {
                  return todoTile(todoList[index]);
                } else {
                  return SizedBox(
                    height: 60,
                  );
                }
              });
        } else if (snapshot.hasError) {
          widgetReturn = Text("Error");
        } else {
          widgetReturn = Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widgetReturn;
      },
    );

    return new Scaffold(
      backgroundColor: colorsScheme[2],
      appBar: new AppBar(
        title: new Text("Todo Knigth"),
      ),
      body: futureLoader,
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget todoTile(Todo todo) {
    return new Container(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
            ),
            onPressed: () => _pushAlertOfDelete(
                todo,
                "You are sure to mark ${todo.title} as done?",
                "Mark as Done",
                colorsScheme[3]),
            iconSize: 24.0,
            splashColor: colorsScheme[2],
            highlightColor: colorsScheme[2],
          ),
          Expanded(
            child: Container(
              child: Text(
                '${todo.title}',
                style: new TextStyle(fontSize: 18.0, height: 1.25),
              ),
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
            ),
          ),
          PopupMenuButton<String>(
            color: colorsScheme[1],
            icon: Icon(Icons.more_vert),
            initialValue: "None",
            onSelected: (choice) {
              if (choice == "Edit") {
                _pushEditTodoScreen(todo);
              }
              if (choice == "Delete") {
                _pushAlertOfDelete(
                    todo,
                    "Are you sure to delete ${todo.title}?",
                    "Delete",
                    colorsScheme[4]);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: "Edit",
                child: Text(
                  "Edit",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const PopupMenuItem<String>(
                value: "Delete",
                child: Text(
                  "Delete",
                  style: TextStyle(fontSize: 18.0),
                ),
              )
            ],
          ),
        ],
      ),
      decoration: new BoxDecoration(
        border: Border(bottom: BorderSide(color: colorsScheme[0], width: 1.0)),
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Add Todo"),
        ),
        body: Container(
          child: new TextField(
            autofocus: true,
            decoration: new InputDecoration(
              hintText: "Add Todo",
              contentPadding: EdgeInsets.only(bottom: -16.0, left: 4.0),
            ),
            onSubmitted: (result) {
              addTodo(result);
              Navigator.pop(context);
            },
          ),
          padding: const EdgeInsets.all(16.0),
        ),
      );
    }));
  }

  void addTodo(String todoTitle) {
    Todo newTodo = Todo();
    newTodo.title = todoTitle;
    newTodo.done = false;
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.insert(newTodo).then((result) {
      newTodo.id = result;
      setState(() {
        todoList.add(newTodo);
      });
    });
  }

  void _pushAlertOfDelete(
      Todo todo, String alertText, String confirmText, Color color) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: color,
            title: new Text(
              alertText,
              style: TextStyle(
                height: 1.5,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(8.0),
              ),
              FlatButton(
                child: Text(confirmText, style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  deleteTodo(todo.id);
                  Navigator.of(context).pop();
                },
                padding: const EdgeInsets.all(8.0),
              )
            ],
          );
        });
  }

  void deleteTodo(int id) {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.delete(id).then((result) {
      setState(() {
        getTodosFromDatabase();
      });
    });
  }

  void _pushEditTodoScreen(Todo todo) {
    final TextEditingController controller = TextEditingController()
      ..text = todo.title;

    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Edit Todo"),
        ),
        body: Container(
          child: new TextField(
            controller: controller,
            autofocus: true,
            decoration: new InputDecoration(
              hintText: "Edit Todo",
              contentPadding: EdgeInsets.only(bottom: -16.0, left: 4.0),
            ),
            onSubmitted: (result) {
              todo.title = result;
              editTodo(todo);
              Navigator.pop(context);
            },
          ),
          padding: const EdgeInsets.all(16.0),
        ),
      );
    }));
  }

  void editTodo(Todo todo) {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.update(todo).then((result) {
      setState(() {
        getTodosFromDatabase();
      });
    });
  }
}
