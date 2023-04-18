import 'package:flutter/material.dart';
import 'database.dart';

class EmptySpacePage extends StatefulWidget {
  @override
  _EmptySpacePageState createState() => _EmptySpacePageState();
}

class _EmptySpacePageState extends State<EmptySpacePage> {
  late Future<List<String>> _emptySpaces;
  final Color _borderColor = Colors.indigo;

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

    for (int i = 0; i < emptySpaces.length; i++) {
      final locationKey = emptySpaces[i];

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
              border: Border.all(
                  color: _borderColor,
                  width: 0.3
              ),
            ),
            child: Center(
              child: Text(
                locationKey,
                style: const TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
      body: Container(
        color: Colors.black87,
        child: FutureBuilder<List<String>>(
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
      ),
    );
  }
}
