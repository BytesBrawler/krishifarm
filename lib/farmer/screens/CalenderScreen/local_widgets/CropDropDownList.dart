// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:krishfarm/models/sample.dart';

class CropDropdownLists extends StatefulWidget {
  final Function(String) callback;
  final String dropdownType;
  final String selectedItems;

  const CropDropdownLists(this.callback, this.dropdownType,
      {super.key, required this.selectedItems});

  @override
  _CropDropdownListState createState() => _CropDropdownListState();
}

class _CropDropdownListState extends State<CropDropdownLists> {
  List<String> items = [];
  String selectedItem = "";

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    bool isEnglish = true; // You might want to pass this from the parent widget

    setState(() {
      selectedItem = widget.selectedItems;
    });
    switch (widget.dropdownType) {
      case 'Crop':
        items = productVarieties.keys.toList();
        // .where((category) =>
        //     category != 'Miscellaneous' &&
        //     !category.contains('Organic') &&
        //     !category.contains('Feed'))
        // .toList();
        break;

      case 'Crop Variety':
        // If a crop has been selected previously, get its varieties
        if (selectedItem.isNotEmpty) {
          items = productVarieties[selectedItem] ?? [];
        } else {
          // Default to showing varieties of the first crop
          // String firstCrop = productVarieties.keys.first;
          // print(firstCrop);

          setState(() {
            items = productVarieties[selectedItem] ?? [];
          });
          setState(() {});
        }
        break;

      case 'Grade':
        items = ['Grade A', 'Grade B', 'Grade C'];
        // Use the same logic as Crop Variety
        // if (selectedItem.isNotEmpty) {
        //   items = productVarieties[selectedItem] ?? [];
        // } else {
        //   String firstCrop = categoryProducts.keys.first;
        //   items = productVarieties[firstCrop] ?? [];
        // }
        break;

      case 'Seed Company':
        items = seedCompanies;
        break;

      default:
        developer.log('Unknown dropdown type: ${widget.dropdownType}');
        items = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = true; // Use actual localization logic

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 360,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: <Widget>[
              customHeader(isEnglish),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, index) => RadioListTile<String>(
                    title: Text(items[index]),
                    groupValue: selectedItem,
                    value: items[index],
                    onChanged: (val) {
                      setState(() {
                        selectedItem = val!;
                      });
                      widget.callback(val!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customHeader(bool isEnglish) {
    String title;
    switch (widget.dropdownType) {
      case 'Crop':
        title = isEnglish ? 'Select a Crop' : 'फसल का चयन करें';
        break;
      case 'Crop Variety':
        title = isEnglish ? 'Select Crop Variety' : 'फसल की किस्म चुनें';
        break;
      case 'Seed Variety':
        title = isEnglish ? 'Select Seed Variety' : 'बीज की किस्म चुनें';
        break;
      case 'Seed Company':
        title = isEnglish ? 'Select Seed Company' : 'बीज कंपनी चुनें';
        break;
      default:
        title = 'Select';
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontFamily: 'Lato',
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.cancel,
              color: Colors.black.withOpacity(0.8),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}


// // // import '../../../services/LocalizationProvider.dart';

// // // class CropDropdownList extends StatefulWidget {
// // //   final Function callback;

// // //   const CropDropdownList(this.callback);

// // //   @override
// // //   _CropDropdownListState createState() => _CropDropdownListState();
// // // }

// // // class _CropDropdownListState extends State<CropDropdownList> {
// // //   List crops = [];
// // //   final _db = FirebaseFirestore.instance;
// // //   String selectedCrop = "";

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

// // //     return Scaffold(
// // //       backgroundColor: Colors.transparent,
// // //       body: Center(
// // //         child: Container(
// // //           height: 360,
// // //           margin: const EdgeInsets.all(20),
// // //           decoration: BoxDecoration(
// // //               color: Colors.white, borderRadius: BorderRadius.circular(15)),
// // //           child: Column(
// // //             children: <Widget>[
// // //               customHeader(isEnglish),
// // //               Container(
// // //                 height: 300,
// // //                 child: FutureBuilder<DocumentSnapshot>(
// // //                     future: _db
// // //                         .collection(
// // //                             isEnglish ? 'configurables' : 'hindiConfigurables')
// // //                         .document('crops')
// // //                         .get(),
// // //                     builder: (context, snapshot) {
// // //                       if (snapshot.connectionState != ConnectionState.waiting &&
// // //                           snapshot.hasData) {
// // //                         if (snapshot.data != null) {
// // //                           crops = snapshot.data['crops'] ?? [];
// // //                         }
// // //                       }
// // //                       return ListView.builder(
// // //                         itemBuilder: (ctx, index) => RadioListTile(
// // //                             title: Text(crops[index].toString()),
// // //                             groupValue: this.selectedCrop,
// // //                             value: crops[index],
// // //                             onChanged: (val) {
// // //                               setState(() => selectedCrop = val);
// // //                               widget.callback(val);
// // //                             }),
// // //                         itemCount: crops.length,
// // //                       );
// // //                     }),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget customHeader(bool isEnglish) {
// // //     return Container(
// // //       padding: const EdgeInsets.only(
// // //         top: 10,
// // //         left: 20,
// // //       ),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: <Widget>[
// // //           Text(
// // //             isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
// // //             style: TextStyle(
// // //               color: Colors.black.withOpacity(0.8),
// // //               fontFamily: 'Lato',
// // //               fontSize: 18,
// // //             ),
// // //           ),
// // //           IconButton(
// // //             icon: Icon(
// // //               Icons.cancel,
// // //               color: Colors.black.withOpacity(0.8),
// // //             ),
// // //             onPressed: () => Navigator.of(context).pop(),
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // import '../../../services/LocalizationProvider.dart';

// // class CropDropdownList extends StatefulWidget {
// //   final Function(String) callback;

// //   const CropDropdownList(this.callback, {Key? key}) : super(key: key);

// //   @override
// //   _CropDropdownListState createState() => _CropDropdownListState();
// // }

// // class _CropDropdownListState extends State<CropDropdownList> {
// //   List<String> crops = [];
// //   final FirebaseFirestore _db = FirebaseFirestore.instance;
// //   String selectedCrop = "";

// //   @override
// //   Widget build(BuildContext context) {
// //     bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: Center(
// //         child: Container(
// //           height: 360,
// //           margin: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(15),
// //           ),
// //           child: Column(
// //             children: <Widget>[
// //               customHeader(isEnglish),
// //               Container(
// //                 height: 300,
// //                 child: FutureBuilder<DocumentSnapshot>(
// //                   future: _db
// //                       .collection(
// //                           isEnglish ? 'configurables' : 'hindiConfigurables')
// //                       .doc('crops')
// //                       .get(),
// //                   builder: (context, snapshot) {
// //                     if (snapshot.connectionState == ConnectionState.waiting) {
// //                       return const Center(child: CircularProgressIndicator());
// //                     }
// //                     if (snapshot.hasData && snapshot.data != null) {
// //                       var data = snapshot.data!.data() as Map<String, dynamic>;
// //                       crops = List<String>.from(data['crops'] ?? []);
// //                     }
// //                     return ListView.builder(
// //                       itemCount: crops.length,
// //                       itemBuilder: (ctx, index) => RadioListTile<String>(
// //                         title: Text(crops[index]),
// //                         groupValue: selectedCrop,
// //                         value: crops[index],
// //                         onChanged: (val) {
// //                           setState(() {
// //                             selectedCrop = val!;
// //                           });
// //                           widget.callback(val!);
// //                         },
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget customHeader(bool isEnglish) {
// //     return Container(
// //       padding: const EdgeInsets.only(
// //         top: 10,
// //         left: 20,
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: <Widget>[
// //           Text(
// //             isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
// //             style: TextStyle(
// //               color: Colors.black.withOpacity(0.8),
// //               fontFamily: 'Lato',
// //               fontSize: 18,
// //             ),
// //           ),
// //           IconButton(
// //             icon: Icon(
// //               Icons.cancel,
// //               color: Colors.black.withOpacity(0.8),
// //             ),
// //             onPressed: () => Navigator.of(context).pop(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class CropDropdownList extends StatefulWidget {
//   final Function(String) callback;

//   const CropDropdownList(this.callback, {Key? key}) : super(key: key);

//   @override
//   _CropDropdownListState createState() => _CropDropdownListState();
// }

// class _CropDropdownListState extends State<CropDropdownList> {
//   List<String> crops = ["Wheat", "Rice", "Maize", "Barley", "Soybean"];
//   String selectedCrop = "";

//   @override
//   Widget build(BuildContext context) {
//     bool isEnglish =
//         true; // Hardcoded for demonstration. Use actual localization logic here.

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: Container(
//           height: 360,
//           margin: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             children: <Widget>[
//               customHeader(isEnglish),
//               Container(
//                 height: 300,
//                 child: ListView.builder(
//                   itemCount: crops.length,
//                   itemBuilder: (ctx, index) => RadioListTile<String>(
//                     title: Text(crops[index]),
//                     groupValue: selectedCrop,
//                     value: crops[index],
//                     onChanged: (val) {
//                       setState(() {
//                         selectedCrop = val!;
//                       });
//                       widget.callback(val!);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget customHeader(bool isEnglish) {
//     return Container(
//       padding: const EdgeInsets.only(
//         top: 10,
//         left: 20,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(
//             isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
//             style: TextStyle(
//               color: Colors.black.withOpacity(0.8),
//               fontFamily: 'Lato',
//               fontSize: 18,
//             ),
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.cancel,
//               color: Colors.black.withOpacity(0.8),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// void showCropDropdown(BuildContext context, Function(String) selectValues) {
//   showDialog(
//     context: context,
//     builder: (context) => CropDropdownList(selectValues),
//   );
// }
