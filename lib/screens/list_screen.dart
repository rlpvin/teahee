import 'package:flutter/material.dart';
import 'details_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  Widget item(String title, String date, String type, BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(type),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsScreen(type: type)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TeaKettle")),
      body: ListView(
        children: [
          item("Morning Reflection", "Apr 22", "Tall", context),
          item("Beach Day", "Apr 20", "Grande", context),
          item("Music Night", "Apr 18", "Venti", context),
        ],
      ),
    );
  }
}
