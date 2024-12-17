import 'dart:io';
import 'package:krishfarm/farmer/screens/CropEstimation.dart';
import 'package:krishfarm/farmer/widgets/CustomLightButton.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../local_widgets/DateField.dart';
import '../../../widgets/ImageInput.dart';
import '../local_widgets/CustomAppBar.dart';
import '../../../widgets/Locationinput.dart';
import '../local_widgets/CropDropdownField.dart';
import '../../../services/CropFieldProvider.dart';
import '../../../services/LocalizationProvider.dart';

class AddCropFieldScreen extends StatefulWidget {
  const AddCropFieldScreen({super.key});

  @override
  _AddCropFieldScreenState createState() => _AddCropFieldScreenState();
}

class _AddCropFieldScreenState extends State<AddCropFieldScreen> {
  String _cropName = "";
  String _cropVariety = "";
  String _seed_variety = "";
  String _seed_company = "";
  String _startTimeString = "";
  Timestamp? _startTimeStamp;
  Position? _position;
  String? _imageUrl;
  File? _image;

  void setCropName(String crop) {
    _cropName = crop;
    setState(() {});
  }

  void setCropVariety(String crop) {
    _cropVariety = crop;
  }

  void setSeedVariety(String crop) {
    _seed_variety = crop;
  }

  void setSeedCompany(String crop) {
    _seed_company = crop;
  }

  void setTimeValues(Timestamp timestamp, String date) {
    _startTimeStamp = timestamp;
    _startTimeString = date;
  }

  void selectLocation(double lat, double long) {
    _position = Position(
      latitude: lat,
      longitude: long,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
      speedAccuracy: 0.0,
    );
  }

  Future<void> selectImage(File image) async {
    setState(() {
      _image = image;
    });

    try {
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('shopPictures/${Path.basename(image.path)}');
      final uploadTask = await firebaseStorageRef.putFile(_image!);
      _imageUrl = await uploadTask.ref.getDownloadURL();
      setState(() {});
    } catch (e) {
      // Handle errors
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: customAppBar(
          context,
          isEnglish ? 'Add Crop Field' : 'फसल का खेत जोड़ें',
          isEnglish,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CropDropdownField(
                setCropName, isEnglish, "Select a Crop", "Crop", ""),
            CropDropdownField(setCropVariety, isEnglish,
                "Select a Crop Variety", "Crop Variety", _cropName),
            CropDropdownField(setSeedVariety, isEnglish, "Select a Grade",
                "Grade", _cropVariety),
            CropDropdownField(setSeedCompany, isEnglish,
                "Select a Seed Company", "Seed Company", _seed_company),
            // CropDropdownField(setCropName, isEnglish, "Select a Crop" , ),
            // CropDropdownField(
            //     setCropVariety, isEnglish, "Select a Crop Variety"),
            // CropDropdownField(
            //     setSeedVariety, isEnglish, "Select a Seed Variety"),
            // CropDropdownField(
            //     setSeedCompany, isEnglish, "Select a Seed Company"),
            DateField(setTimeValues, isEnglish),
            ImageInput(selectImage, isEnglish: isEnglish),
            LocationInput(selectLocation, isEnglish: isEnglish),
            ElevatedButton(
                onPressed: () {
                  // print(_cropName);
                  // print(_cropVariety);
                  // print(_seed_variety);
                  // print(_seed_company);
                  // print(_startTimeString);
                  // print(_position);
                  // print(_imageUrl);

                  CropFieldProvider.uploadCropField(
                    context: context,
                    cropName: _cropName,
                    startTimestamp: _startTimeStamp,
                    startDate: _startTimeString,
                    position: _position,
                    imageUrl: _imageUrl ?? '',
                  );
                },
                child: Text(" Direct Submit")),

            ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CropProductionScreen(
                              map: {
                                "cropName": _cropName,
                                "startTimestamp": _startTimeStamp,
                                "startDate": _startTimeString,
                                "position": _position,
                                "imageUrl": _imageUrl ?? '',
                                "cropVariety": _cropVariety,
                                "seedVariety": _seed_variety,
                                "seedCompany": _seed_company,
                              },
                            ))),
                // onPressed: () {
                //   // print(_cropName);
                //   // print(_cropVariety);
                //   // print(_seed_variety);
                //   // print(_seed_company);
                //   // print(_startTimeString);
                //   // print(_position);
                //   // print(_imageUrl);

                //   CropFieldProvider.uploadCropField(
                //     context: context,
                //     cropName: _cropName,
                //     startTimestamp: _startTimeStamp,
                //     startDate: _startTimeString,
                //     position: _position,
                //     imageUrl: _imageUrl ?? '',
                //   );
                // },
                child: Text(isEnglish ? 'SUBMIT' : 'पुष्टि करें'))
            // PrimaryButton(
            //   text: isEnglish ? 'SUBMIT' : 'पुष्टि करें',
            //   press: () => CropFieldProvider.uploadCropField(
            //     context: context,
            //     cropName: _cropName,
            //     startTimestamp: _startTimeStamp,
            //     startDate: _startTimeString,
            //     position: _position,
            //     imageUrl: _imageUrl ?? '',
            //   ),
            //   color: Colors.black,
            // ),
            ,
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
