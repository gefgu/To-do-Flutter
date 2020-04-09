import 'package:flutter/material.dart';
import 'package:tododark/database_helpers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Knight',
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        brightness: Brightness.dark,
        accentColor: Colors.blueGrey,
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

  @override
  void initState() {
    super.initState();
    getTodosFromDatabase();
  }

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
                  return SizedBox(height: 60,);
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
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            onPressed: () => _pushMarkAsDone(todo),
            iconSize: 24.0,
          ),
          Expanded(
            child: Container(
              child: Text(
                '${todo.title}',
                style: new TextStyle(
                  fontSize: 18.0,
                ),
              ),
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 18.0,
            onPressed: () => {},
          )
        ],
      ),
      decoration: new BoxDecoration(
        border:
          Border(bottom: BorderSide(color: Colors.blueGrey, width: 4.0)),
        color: Colors.black12,
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
              contentPadding: const EdgeInsets.all(8.0),
              hintText: "Add Todo",
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

  void _pushMarkAsDone(Todo todo) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("You are sure to mark ${todo.title} as done?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Mark as Done"),
                onPressed: () {
                  deleteTodo(todo.id);
                  Navigator.of(context).pop();
                },
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
}
