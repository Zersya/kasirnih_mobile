part of 'new_item_facilities_bloc.dart';

class NewItemFacilitiesRepository {
  final Firestore _firestore = Firestore.instance;

  Future<List<NewItemFacilities>> loadListNewFacilities() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString(kUserDocIdKey);

    final doc = await _firestore
        .collection('users')
        .document(userKey)
        .collection('new_item_facilities')
        .getDocuments();

    List<NewItemFacilities> listName =
        doc.documents.map((e) => NewItemFacilities.fromMap(e.data)).toList();
    return listName;
  }

  Future<bool> addNewFacilities(NewItemFacilitiesAdd event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString(kUserDocIdKey);

    final doc = await _firestore.collection('users').document(userKey);
    final collection = doc.collection('new_item_facilities');

    final NewItemFacilities item = NewItemFacilities(
        collection.document().documentID, event.itemName, false);

    await collection.document(item.docId).setData(item.toMap());
    toastSuccess(
        tr('new_item_facilities_screen.success_add_new_item_facilities'));
    return true;
  }

  Future<bool> updateValue(NewItemFacilitiesChangeValue event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString(kUserDocIdKey);

    final doc = await _firestore
        .collection('users')
        .document(userKey)
        .collection('new_item_facilities')
        .getDocuments();

    final ref = doc.documents
        .firstWhere((element) => event.item.docId == element.documentID)
        .reference;

    final result = await _firestore.runTransaction((transaction) async {
      final freshsnap =
          await transaction.get(ref).catchError((err) => throw err);
      await transaction.update(freshsnap.reference, event.item.toMap());
    }).catchError((err) {
      toastError(err.message);
      return null;
    });

    if (result != null) {
      return true;
    } else {
      return false;
    }
  }
}