import 'package:flutter/material.dart';
import 'database.dart';

class EmptySpacePage extends StatefulWidget {
  @override
  _EmptySpacePageState createState() => _EmptySpacePageState();
}

class _EmptySpacePageState extends State<EmptySpacePage> {
  late Future<List<String>> _emptySpaces;
  final Color _color1 = Colors.lightBlue;
  final Color _color2 = Colors.lightGreen;

  @override
  void initState() {
    super.initState();
    _emptySpaces = getEmptySpaces();
  }

  Future<void> _refresh() async {
    setState(() {
      _emptySpaces = getEmptySpaces();
    });
  }

  List<Widget> buildLocationList(List<String> emptySpaces) {
    List<Widget> locationList = [];
    Color lastColor = _color1;

    for (int i = 0; i < emptySpaces.length; i++) {
      final locationKey = emptySpaces[i];
      final prevLocationKey = i > 0 ? emptySpaces[i - 1] : null;

      if (prevLocationKey != null) {
        final prevRack = prevLocationKey.split('_')[1];
        final currentRack = locationKey.split('_')[1];

        if (prevRack != currentRack) {
          lastColor = (lastColor == _color1) ? _color2 : _color1;
        }
      }

      locationList.add(
        InkWell(
          onTap: () {
            Navigator.pop(context, locationKey);
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: lastColor,
            ),
            child: Text(
              locationKey,
              style: TextStyle(fontSize: 20, color: (lastColor == _color2) ? Colors.black : Colors.white),
            ),
          ),
        ),
      );
    }

    return locationList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty Spaces'),
      ),
      body: FutureBuilder<List<String>>(
        future: _emptySpaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final emptySpaces = snapshot.data!;
            final locationList = buildLocationList(emptySpaces);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: locationList,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}