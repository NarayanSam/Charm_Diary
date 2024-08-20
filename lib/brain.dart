import 'package:charm/habit_tracker.dart';
import 'package:charm/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BPage extends StatefulWidget {
  @override
  _BPageState createState() => _BPageState();
}

class _BPageState extends State<BPage> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.addAll(prefs.getStringList('notes') ?? []);
    });
  }

  _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', _notes);
  }

  _addNote() {
    String newNote = _noteController.text;
    if (newNote.isNotEmpty) {
      setState(() {
        _notes.add(newNote);
      });
      _noteController.clear();
      _saveNotes();
    }
  }

  _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Brain Dump',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book, // User logo
                        color: Colors.white,
                        size: 30.0,
                      ),
                      SizedBox(width: 8.0), // Space between the icon and text
                      Text(
                        'Charm Diary',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyHomePage(
                          title: 'Charm Diary',
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Habit Tracker'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HabitTrackerPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline_rounded),
            title: const Text('Brain Dump'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BPage()),
              );
            },
          ),
        ]),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_notes[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteNote(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Add a new note',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
