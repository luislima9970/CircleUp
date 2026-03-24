class UserService {
  // Simula a base de dados em memória
  static int _points = 0;

  Future<int> loadPoints() async {
    // TODO: substituir por Firestore
    // final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // return doc.data()?['points'] ?? 0;
    return _points;
  }

  Future<void> addPoints(int amount) async {
    // TODO: substituir por Firestore
    // await FirebaseFirestore.instance.collection('users').doc(userId)
    //     .update({'points': FieldValue.increment(amount)});
    _points += amount;
  }

  static void reset() {
    _points = 0;
  }
}