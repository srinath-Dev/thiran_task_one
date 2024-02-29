import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/DatabaseHelper.dart';
import '../providers/RepositoryProvider.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initDatabase();
    Provider.of<RepositoryProvider>(context, listen: false).fetchAndSaveRepositories(false);
  }

  _initDatabase() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories(Thiran Task One)'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<RepositoryProvider>(context, listen: false).refreshRepositories();
        },
        child: Consumer<RepositoryProvider>(
          builder: (context, provider, _) {
            if (provider.repositories.isEmpty) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                itemCount: provider.repositories.length,
                itemBuilder: (context, index) {
                  final repository = provider.repositories[index];
                  return ListTile(
                    title: Text(repository.name),
                    subtitle: Text(repository.owner),
                    trailing: Text('${repository.stars} stars'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
