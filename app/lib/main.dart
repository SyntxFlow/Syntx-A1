import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ffi/ffi.dart';

import 'screens/demo.dart';
import 'screens/chat.dart';
import 'screens/splash_screen.dart';

final DynamicLibrary _nativeLib = () {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libsyntx.so');
  }
  return DynamicLibrary.process();
}();

typedef TambahC = Int32 Function(Int32 a, Int32 b);
typedef TambahDart = int Function(int a, int b);

typedef GetVersionC = Pointer<Utf8> Function();
typedef GetVersionDart = Pointer<Utf8> Function();

final TambahDart tambahNative = _nativeLib.lookup<NativeFunction<TambahC>>('tambah').asFunction();
final GetVersionDart getVersionNative = _nativeLib.lookup<NativeFunction<GetVersionC>>('get_version').asFunction();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Syntx A1',
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // TRY THIS: Try running your application with "flutter run". You'll see
      //   // the application has a purple toolbar. Then, without quitting the app,
      //   // try changing the seedColor in the colorScheme below to Colors.green
      //   // and then invoke "hot reload" (save your changes or press the "hot
      //   // reload" button in a Flutter-supported IDE, or press "r" if you used
      //   // the command line to start the app).
      //   //
      //   // Notice that the counter didn't reset back to zero; the application
      //   // state is not lost during the reload. To reset the state, use hot
      //   // restart instead.
      //   //
      //   // This works for code too, not just values: Most code changes can be
      //   // tested with just a hot reload.
      //   colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      // ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return CupertinoPageRoute(builder: (context) => const SplashScreen());
          case '/home':
            return CupertinoPageRoute(builder: (context) => MyHomePage(title: "Flutter Home Page"));
          case '/demo':
            return CupertinoPageRoute(builder: (context) => AudioStreamingApp());
          case '/chat':
            return CupertinoPageRoute(builder: (context) => ChatScreen());
          default:
            return null;
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _aksesFungsi() {
    int result = tambahNative(1, 1);
    print(result);
  }

  void _aksesFungsiVersi() {
    Pointer<Utf8> result = getVersionNative();
    print(result.toDartString());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.black,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        middle: Text(widget.title),
      ),
      child: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton.filled(
              onPressed: () => {Navigator.of(context).pushNamed("/chat")},
              child: Text("Pindah halaman Chat"),
            ),
            CupertinoButton.filled(
              onPressed: () => {Navigator.of(context).pushNamed("/demo")},
              child: Text("Pindah halaman"),
            ),
            CupertinoButton.filled(
              onPressed: _aksesFungsi,
              child: Text("Coba akses fungsi ke c++"),
            ),
            CupertinoButton.filled(
              onPressed: _aksesFungsiVersi,
              child: Text("Coba akses fungsi ke c++ ( String, char* Return )"),
            ),
            const Text('You have pushed the button this many times:'),
          ],
        ),
      ),
    );
  }
}