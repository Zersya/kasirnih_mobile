part of 'items_widget_bloc.dart';

class ItemsWidgetRepository {
  final Firestore _firestore = Firestore.instance;
  final storage = FlutterSecureStorage();

  Future<Stream<List<Item>>> loadItems(
      ItemsWidgetLoad event, ItemsWidgetState state) async {
    final userKey = await storage.read(key: kUserDocIdKey);
    final storeKey = await storage.read(key: kDefaultStore);

    Stream<List<Item>> items;
    final List<String> names = event.categories.map((e) => e.name).toList();
    if (names.isEmpty) {
      items = _firestore
          .collection('stores')
          .document(storeKey)
          .collection('items')
          .snapshots()
          .map((event) =>
              event.documents.map((e) => Item.fromMap(e.data)).toList());
    } else {
      items = _firestore
          .collection('stores')
          .document(storeKey)
          .collection('items')
          .where('category_name', whereIn: names)
          .snapshots()
          .map((event) =>
              event.documents.map((e) => Item.fromMap(e.data)).toList());
    }
    return items;
  }

  Future<Stream<List<Item>>> searchItem(
      ItemsWidgetSearch event, ItemsWidgetState state) async {
    final userKey = await storage.read(key: kUserDocIdKey);
    final storeKey = await storage.read(key: kDefaultStore);

    final items = _firestore
        .collection('stores')
        .document(storeKey)
        .collection('items')
        .where('item_name',
            isGreaterThanOrEqualTo: event.name,
            isLessThanOrEqualTo: '${event.name}~')
        .snapshots()
        .map((event) =>
            event.documents.map((e) => Item.fromMap(e.data)).toList());

    return items;
  }
}
