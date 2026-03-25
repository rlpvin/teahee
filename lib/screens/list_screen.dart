import 'package:flutter/material.dart';
import 'details_screen.dart';
import '../models/teacup.dart';
import '../services/storage_service.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final StorageService _storageService = StorageService();
  List<TeaCup> _teaCups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeaCups();
  }

  Future<void> _loadTeaCups() async {
    setState(() => _isLoading = true);
    final cups = await _storageService.getAllTeaCups();
    setState(() {
      _teaCups = cups;
      _isLoading = false;
    });
  }

  Widget item(TeaCup teacup, BuildContext context) {
    return ListTile(
      title: Text(teacup.title),
      subtitle: Text(teacup.date),
      trailing: Text(teacup.type),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(teacup: teacup)),
        );
        _loadTeaCups();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TeaKettle")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teaCups.isEmpty
              ? const Center(child: Text("No TeaCups yet. Pour one!"))
              : ListView.builder(
                  itemCount: _teaCups.length,
                  itemBuilder: (context, index) {
                    return item(_teaCups[index], context);
                  },
                ),
    );
  }
}
