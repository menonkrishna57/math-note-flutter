import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final DrawingController _drawingController = DrawingController();
  GenerativeModel model = GenerativeModel(
      model: "gemini-1.5-pro-latest",
      apiKey: "AIzaSyCXVZ7EyuQOpiZxijmSFhenLwtvMdmF7nU");
  bool isErasing = false;
  
  void generate() async {
    try {
      final image = await _drawingController.getImageData();
      if (image == null) {
        return;
      }
      final prompt = [
        Content.multi([
          TextPart(
            "What will be the result for this math problem? Only say the number nothing else. If there are multiple problems, answer all from top to bottom.",
          ),
          DataPart(
            "image/png",
            image.buffer.asUint8List(),
          ),
        ])
      ];
      final result = await model.generateContent(prompt);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Solution"),
            content: Text(result.text ?? "No Output"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// Suggested code may be subject to a license. Learn more: ~LicenseLog:4291839565.
      appBar: AppBar(
        title: const Text('Math Notes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: DrawingBoard(
                  controller: _drawingController,
                  background: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            IconButton(
                onPressed: () => _drawingController.undo(),
                icon: const Icon(Icons.undo),
              ),
              IconButton(
                onPressed: () => _drawingController.redo(),
                icon: const Icon(Icons.redo),
              ),
              IconButton(
                onPressed: generate,
                icon: const Image(
                  image: AssetImage("assets/gemini-icon.png"),
                  height: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isErasing = !isErasing;
                  });
                  _drawingController
                      .setPaintContent(isErasing ? Eraser() : SimpleLine());
                },
                icon: Icon(isErasing ? Icons.edit : Icons.backspace),
              ),
              IconButton(
                onPressed: () => _drawingController.clear(),
                icon: const Icon(Icons.clear),
              ),
            ],
          )
        ],
      ),
    );
  }
}
