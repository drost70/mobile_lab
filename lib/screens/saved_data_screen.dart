import 'package:flutter/material.dart';
import 'package:my_project/services/serial_service.dart';

class SavedDataScreen extends StatefulWidget {
  const SavedDataScreen({super.key});

  @override
  SavedDataScreenState createState() => SavedDataScreenState();
}

class SavedDataScreenState extends State<SavedDataScreen> {
  String _savedData = 'Дані відсутні';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final data = await SerialService.instance.readSavedData();
    if (!mounted) return;
    setState(() {
      _savedData = data ?? 'Дані не знайдені або помилка читання';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Збережені дані'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _savedData,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSavedData,
        tooltip: 'Оновити',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
