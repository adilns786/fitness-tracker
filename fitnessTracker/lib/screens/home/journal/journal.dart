// journal_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late Map<DateTime, String> _journalEntries; // Store journal entries by date
  late DateTime _selectedDay;
  late String _selectedEntry; // Store the selected journal entry for editing

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _journalEntries = {}; // Initialize journal entries
    _selectedEntry = '';
  }

  // Function to update the entry for the selected day
  void _updateEntry() {
    setState(() {
      if (_selectedEntry.isNotEmpty) {
        _journalEntries[_selectedDay] = _selectedEntry;
      } else {
        _journalEntries.remove(_selectedDay); // Remove entry if empty
      }
      _selectedEntry = ''; // Reset entry after saving
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Page')),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar<DateTime>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _selectedEntry = _journalEntries[selectedDay] ??
                    ''; // Load entry for the selected day
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // TextField for editing journal entries
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your journal entry...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _selectedEntry = value;
              },
              controller: TextEditingController(text: _selectedEntry),
            ),
          ),
          ElevatedButton(
            onPressed: _updateEntry,
            child: const Text('Save Entry'),
          ),
          // Display all journal entries
          Expanded(
            child: ListView(
              children: _journalEntries.entries.map((entry) {
                return ListTile(
                  title: Text(
                    '${entry.key.toLocal()}'.split(' ')[0], // Display only date
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
