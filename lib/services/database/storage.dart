import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sql_treino/services/cryptography/cryptography.dart';

class UserDB {
  Future post(Map data, {bool create = false}) async {
    if (data['password'].contains(RegExp(r"[^a-zA-Z0-9 .()!@#$%&]"))) {
      return "senha";
    } else if (create) {
      final user = await show(data['email']);
      if (user != null) {
        return "e-mail";
      }
    }
    data['password'] = Cryptography.encrypt(data['password']);
    await Firestore.instance
        .collection("users")
        .document(data['email'])
        .setData(data);
  }

  Future<List<Map>> list() async {
    // {birthday: str, data: {colorgamepts: int, todos: [{ok: bool, title: str}]}, email: str, name: str, password: str}
    final response =
        await Firestore.instance.collection("users").getDocuments();
    return response.documents.map((e) => e.data).toList();
  }

  Future<Map> show(String email) async {
    final all = await list();
    final valids = all.where((user) => user['email'] == email);
    return valids.length > 0 ? valids.first : null;
  }

  Future delete(String email) async {
    Firestore.instance.collection("users").document(email).delete();
  }
}

class WorkoutDB {
  Future post(String userEmail, String name, List<List> data) async {
    // data: [["name", "value"], ["name", "value"]]
    await Firestore.instance
        .collection("users")
        .document(userEmail)
        .collection("workouts")
        .document(name)
        .setData(<String, List>{
      "items": data
          .map((e) => <String, int>{e[0]: int.parse(e[1])})
          .toList() // [{"name": "value"}, {"name": "value"}]
    });
  }

  Future<List<String>> list(String userEmail) async {
    // ["name1", "name2", "name3"]

    final response = await Firestore.instance
        .collection("users")
        .document(userEmail)
        .collection("workouts")
        .getDocuments();

    return response.documents.map((e) => e.documentID).toList();
  }

  Future<List<Map>> show(String userEmail, String name) async {
    // [["name", "value"], ["name", "value"]]
    final response = await Firestore.instance
        .collection("users")
        .document(userEmail)
        .collection("workouts")
        .document(name)
        .get();
    return response.data["items"].cast<Map<String, dynamic>>();
  }

  Future delete(String userEmail, String name) async {
    Firestore.instance
        .collection("users")
        .document(userEmail)
        .collection("workouts")
        .document(name)
        .delete();
  }
}
