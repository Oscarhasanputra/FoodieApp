import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class History {
  final DocumentReference collection;
  History(this.collection);
  static final db = FirebaseFirestore.instance;
  static final table = "history";

  static CollectionReference getCollection() {
    final historyCollect = db.collection(table);
    return historyCollect;
  }

  static History getHistoryCollection(String id) {
    final historyCollect = getCollection().doc(id);
    return History(historyCollect);
  }
}
