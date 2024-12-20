import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Ujer;
import '../models/User.dart';
import '../models/Product.dart';
import '../models/Calender.dart';
import '../models/CropField.dart';

class UserDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User> streamUser(String id) {
    print(id);
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snapshot) => User.fromFirestore(snapshot));
  }

  Future<User?> getUser(String id) async {
    try {
      print(id);
      DocumentSnapshot snapshot = await _db.collection('users').doc(id).get();
      print(snapshot);
      if (!snapshot.exists) {
        return null; // Document does not exist
      }
      print("hello");
      return User.fromFirestore(snapshot);
    } catch (e) {
      // Log error or handle it as per your app's needs
      print('Error fetching user: $e');
      return null;
    }
  }

  // Stream<Product> streamProduct(String id) {
  //   return _db
  //       .collection('products')
  //       .doc(id)
  //       .snapshots()
  //       .map((snapshot) => Product.fromFirestore(snapshot));
  // }

  // Future<Product> getProduct(String id) async {
  //   DocumentSnapshot snapshot = await _db.collection('products').doc(id).get();
  //   return Product.fromFirestore(snapshot);
  // }

  Stream<CropField> streamCropField(String id) {
    return _db
        .collection('cropfields')
        .doc(id)
        .snapshots()
        .map((snapshot) => CropField.fromFirestore(snapshot));
  }

  Future<CropField> getCropField(String id) async {
    DocumentSnapshot snapshot =
        await _db.collection('cropfields').doc(id).get();
    return CropField.fromFirestore(snapshot);
  }

  Future<List<CropField>> getUserCropFields() async {
    try {
      // Get the current user
      Ujer.User? userd = Ujer.FirebaseAuth.instance.currentUser;

      if (userd == null) {
        throw Exception('No user is currently signed in.');
      }

      String userId = userd.uid;
      print(userId);

      // Query Firestore to find all crop fields for the user
      QuerySnapshot querySnapshot = await _db
          .collection('cropfields')
          .where('userId', isEqualTo: userId)
          .get();

      // Map the documents to a list of CropField objects
      List<CropField> cropFields = querySnapshot.docs
          .map((doc) => CropField.fromFirestore(doc))
          .toList();

      return cropFields;
    } catch (e) {
      print('Error fetching user crop fields: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Stream<Calender> streamCalender(String id) {
    print(id);
    Stream<Calender> calender = _db
        .collection('cropData')
        .doc(id)
        //.doc(id)
        .snapshots()
        .map((snapshot) => Calender.fromFirestore(snapshot));
    print(calender.first);
    return calender;
    // return _db
    //     .collection('cropData')
    //     .doc(id)
    //     .snapshots()
    //     .map((snapshot) => Calender.fromFirestore(snapshot));
  }
}
