import 'package:flutter/material.dart';

import 'package:cross_board/cross_board.dart';

void main() {
  runApp(const CrossBoardExampleApp());
}

class CrossBoardExampleApp extends StatelessWidget {
  const CrossBoardExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CrossBoardExampleHome(),
    );
  }
}

class CrossBoardExampleHome extends StatefulWidget {
  const CrossBoardExampleHome({Key? key}) : super(key: key);

  @override
  State<CrossBoardExampleHome> createState() => _CrossBoardExampleHomeState();
}

class _CrossBoardExampleHomeState extends State<CrossBoardExampleHome> {
  String _value = '';
  bool _permissionGranted = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _value);
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: !_permissionGranted
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    controller: _controller,
                    onChanged: (text) {
                      setState(
                        () {
                          _value = text;
                        },
                      );
                    },
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _cut,
                        child: const Text('cut'),
                      ),
                      ElevatedButton(
                        onPressed: _copy,
                        child: const Text('copy'),
                      ),
                      ElevatedButton(
                        onPressed: _paste,
                        child: const Text('paste'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  void _cut() {
    CrossBoard.copy(_value);
    setState(() {
      _value = '';
      _controller.text = '';
    });
  }

  void _copy() {
    CrossBoard.copy(_value);
  }

  void _paste() {
    CrossBoard.paste().then((value) {
      setState(() {
        _value = value;
        _controller.text = value;
      });
    });
  }

  void _requestPermission() {
    CrossBoard.requestPermission().then((value) {
      setState(() {
        _permissionGranted = value;
      });
    });
  }
}
