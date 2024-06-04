import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserSearch extends SearchDelegate<String> {
  final List<DocumentSnapshot> users;

  UserSearch(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildUserList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildUserList();
  }

  Widget _buildUserList() {
    final suggestionList = query.isEmpty
        ? users
        : users
            .where((user) =>
                (user.data() as Map<String, dynamic>)['name']
                    ?.toString()
                    .startsWith(query) ??
                false)
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
              (suggestionList[index].data() as Map<String, dynamic>)['name']),
          onTap: () {
            close(context,
                (suggestionList[index].data() as Map<String, dynamic>)['name']);
          },
        );
      },
    );
  }
}
