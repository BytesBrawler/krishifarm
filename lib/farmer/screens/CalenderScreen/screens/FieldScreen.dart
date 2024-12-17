import 'package:flutter/material.dart';
import 'package:krishfarm/farmer/screens/CalenderScreen/local_widgets/crop_field_dailog.dart';
import 'package:krishfarm/screens/edit_product/edit_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/CropField.dart';
import '../local_widgets/FieldCard.dart';
import '../local_widgets/EmptyBanner.dart';
import '../../../routing/Application.dart';
import '../local_widgets/CustomAppBar.dart';
import '../../../widgets/LoadingSpinner.dart';
import '../../../services/UserDatabaseService.dart';
import '../../../services/LocalizationProvider.dart';

class FieldScreen extends StatelessWidget {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserDatabaseService userDatabaseService = UserDatabaseService();

  FieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
      appBar: customAppBar(
          context, isEnglish ? 'Crop Calendar' : 'फसल कैलेंडर', isEnglish),
      backgroundColor: Colors.white,
      body: user == null
          ? loadingSpinner()
          : StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('cropfields')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loadingSpinner();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return emptyBanner(context);
                }
                final docs = snapshot.data!.docs;
                final fields =
                    docs.map((doc) => CropField.fromFirestore(doc)).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (ctx, index) =>
                      fieldCard(context, fields[index], isEnglish),
                  itemCount: fields.length,
                );
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        child: Icon(
          Icons.add_circle,
          color: Colors.white.withOpacity(0.8),
        ),
        // onPressed: () => Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => EditProductScreen(
        //             title: "Add Crop",
        //           )),
        // ),
        onPressed: () => showCropFieldAdditionOptions(context),
        // Application.router.navigateTo(context, '/add-crop-field'),
      ),
    );
  }

  // Function to show the dialog
  void showCropFieldAdditionOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Crop Field',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Directly Add Fields
              ElevatedButton(
                onPressed: () {
                  // Navigator.of(ctx).pop(); // Close the first dialog
                  // showDialog(
                  //   context: context,
                  //   builder: (context) =>
                  Application.router.navigateTo(context, '/add-crop-field');
                  //  );
                },
                child: Text('Directly Add Fields'),
              ),
              SizedBox(height: 16),

              // Option 2: AI Recommendation
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropAdvisorScreen(),
                      )); // Close the first dialog

                  // Navigate to Crop Advisor Screen or show recommendations
                  // This is a placeholder - adjust as per your app's navigation
                  // Application.router.navigateTo(context, '/crop-advisor');
                },
                child: Text('Get AI Recommendations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
