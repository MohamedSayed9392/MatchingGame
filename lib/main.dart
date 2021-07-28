import 'package:flutter/material.dart';
import 'package:matching_game_flutter/model/item_model.dart';
import 'package:matching_game_flutter/model/line_painter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Matching Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset start;
  Offset end;
  List<ItemModel> itemList;
  List<ItemModel> itemList2;
  GlobalKey key1 = GlobalKey();
  GlobalKey key2 = GlobalKey();
  GlobalKey key3 = GlobalKey();
  GlobalKey key4 = GlobalKey();
  GlobalKey key5 = GlobalKey();

  @override
  void initState() {
    initList();
    super.initState();
  }

  void initList() {
    itemList = [
      ItemModel('Red', Colors.red, key1),
      ItemModel('Black', Colors.black, key2),
      ItemModel('Blue', Colors.blue, key3),
      ItemModel('Green', Colors.green, key4),
      ItemModel('Yellow', Colors.yellow, key5),
    ];
    itemList2 = List<ItemModel>.from(itemList);
    itemList2.shuffle();
    itemList.shuffle();
  }

  List<Offset> startPoints = [];
  List<Offset> endPoints = [];
  List<Widget> customPainters = [];
  List<String> answers = [];

  var appBarSize;
  var draggedItems = [];

  var screenWidth = 300.0;
  var screenHeight = 400.0;
  @override
  Widget build(BuildContext context) {
    GestureDetector gestureDetector = GestureDetector(
      onPanStart: (details) {
        setState(() {
          start = details.localPosition;
          end = null;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          end = details.localPosition;
        });
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: LinePainter(start, end),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(
          icon: Icon(Icons.undo),
          onPressed: (){
            if(customPainters.isNotEmpty){
              setState((){
                customPainters.removeLast();
                answers.removeLast();
                startPoints.removeLast();
                endPoints.removeLast();
                draggedItems.removeLast();
              });
            }
          },
        ),],
      ),
      body: Builder(builder: (context) {
        appBarSize = Scaffold.of(context).appBarMaxHeight;
        return Container(
          width:screenWidth,
          height:screenHeight,
          child: Center(
            child: Stack(children: [
              IgnorePointer(
                child: gestureDetector,
              ),
              Row(
                children: [
                  Column(
                    children: itemList
                        .map(
                          (e) => Listener(
                            onPointerMove: (event) {
                              if(!draggedItems.contains(itemList.indexOf(e))) {
                                var item = DragUpdateDetails(
                                    delta: Offset.zero,
                                    globalPosition: event.position,
                                    localPosition: Offset(event.position.dx,
                                        event.position.dy - appBarSize));

                                gestureDetector.onPanUpdate(item);
                              }
                            },
                            child: Draggable<ItemModel>(
                              onDragEnd: (draggableDetails) {
                                print("accepted : ${draggableDetails.wasAccepted}");

                                if(draggableDetails.wasAccepted) {
                                  startPoints.add(start);
                                  endPoints.add(end);

                                  customPainters.add(IgnorePointer(
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter: LinePainter(
                                            startPoints.last, endPoints.last),
                                      )));

                                  draggedItems.add(itemList.indexOf(e));
                                }

                                setState(() {
                                  start = Offset.zero;
                                  end = Offset.zero;
                                });
                              },
                              onDragStarted: () {
                                RenderBox render =
                                    e.key.currentContext.findRenderObject();
                                Offset centerWidget = Offset(
                                    render.size.width / 2,
                                    render.size.height / 2 - appBarSize);
                                gestureDetector.onPanStart(
                                  DragStartDetails(
                                    localPosition: render.localToGlobal(
                                      centerWidget,
                                    ),
                                  ),
                                );
                              },
                              data: e,
                              child: Padding(
                                key: e.key,
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  e.name,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              feedback: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  e.name,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              childWhenDragging: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  e.name,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  Spacer(),
                  Column(
                    children: itemList2
                        .map(
                          (e) => DragTarget<ItemModel>(
                            onWillAccept: (data) {
                              print("data : $data");
                              return true;
                            },
                            onAccept: (data) {
                              if (data.name == e.name) {
                                setState(() {
                                  //itemList.remove(e);
                                  //itemList2.remove(e);
                                });
                              }
                              answers.add("${data.name}##${e.name}");
                              print("answers : $answers");
                            },
                            builder: (context, onAccepted, onRejected) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 100,
                                  height: 50,
                                  color: e.color,
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
              Stack(
                children: customPainters,
              )
            ]),
          ),
        );
      }),
    );
  }
}
