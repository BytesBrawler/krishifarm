// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';

import 'package:krishfarm/farmer/screens/CalenderScreen/screens/AddCropFieldScreen.dart'; // Import for jsonEncode

class CropAdvisorScreen extends StatefulWidget {
  @override
  _CropAdvisorScreenState createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nitrogen = ''; // Variable to hold nitrogen value
  String _phosphorus = ''; // Variable to hold phosphorus value
  String _potassium = ''; // Variable to hold potassium value
  String _temperature = ''; // Variable to hold temperature value
  String _humidity = ''; // Variable to hold humidity value
  String _ph = ''; // Variable to hold pH value
  String _rainfall = ''; // Variable to hold rainfall value
  String _suggestedCrop = ''; // Variable to hold the suggested crop

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Advisor'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Nitrogen Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nitrogen (N)',
                    hintText: 'Enter a value between 0 and 150',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter nitrogen value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 150) {
                      return 'Value must be between 0 and 150';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _nitrogen = value,
                ),
                SizedBox(height: 16),

                // Phosphorus Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phosphorus (P)',
                    hintText: 'Enter a value between 0 and 150',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phosphorus value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 150) {
                      return 'Value must be between 0 and 150';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _phosphorus = value,
                ),
                SizedBox(height: 16),

                // Potassium Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Potassium (K)',
                    hintText: 'Enter a value between 0 and 210',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter potassium value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 210) {
                      return 'Value must be between 0 and 210';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _potassium = value,
                ),
                SizedBox(height: 16),

                // Temperature Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Temperature (°C)',
                    hintText: 'Enter a value between 0 and 60',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter temperature value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 60) {
                      return 'Value must be between 0 and 60';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _temperature = value,
                ),
                SizedBox(height: 16),

                // Humidity Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Humidity (%)',
                    hintText: 'Enter a value between 10 and 100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter humidity value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 10 || intValue > 100) {
                      return 'Value must be between 10 and 100';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _humidity = value,
                ),
                SizedBox(height: 16),

                // pH Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Soil pH',
                    hintText: 'Enter a value between 0 and 14',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pH value';
                    }
                    final intValue = double.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 14) {
                      return 'Value must be between 0 and 14';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _ph = value,
                ),
                SizedBox(height: 16),

                // Rainfall Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Rainfall (mm)',
                    hintText: 'Enter a value between 0 and 300',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rainfall value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 300) {
                      return 'Value must be between 0 and 300';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _rainfall = value,
                ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Format the data for submission
                      var submissionData = [
                        {
                          "N": _nitrogen,
                          "P": _phosphorus,
                          "K": _potassium,
                          "temperature": _temperature,
                          "humidity": _humidity,
                          "ph": _ph,
                          "rainfall": _rainfall,
                        }
                      ];

                      // Send the data to the specified URL
                      var response = await http.post(
                        Uri.parse(
                            'https://dcac-103-232-241-223.ngrok-free.app/api/crop-recommender'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(submissionData),
                      );

                      if (response.statusCode == 200) {
                        // Handle successful response
                        var responseData = jsonDecode(response.body);
                        print(responseData);
                        // Check if the response is a list and extract the prediction
                        if (responseData.isNotEmpty &&
                            responseData['prediction'] != null) {
                          _suggestedCrop = responseData[
                              'prediction']; // Extract the predicted crop
                        } else {
                          _suggestedCrop =
                              'No prediction available'; // Handle case where prediction is null
                        }
                        print('Data submitted successfully: ${response.body}');
                      } else {
                        // Handle error response
                        print('Failed to submit data: ${response.statusCode}');
                      }

                      setState(() {}); // Update UI
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Get Crop Suggestions'),
                  ),
                ),

                // Suggested Crop Output
                if (_suggestedCrop.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Suggested Crop for Your Location:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCropFieldScreen()),
                          ),
                          child: Chip(
                            label: Text(_suggestedCrop),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// // class CropPriceAdvisorScreen extends StatefulWidget {
// //   @override
// //   _CropPriceAdvisorScreenState createState() => _CropPriceAdvisorScreenState();
// // }

// // class _CropPriceAdvisorScreenState extends State<CropPriceAdvisorScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   String? _selectedState;
// //   String _district = '';
// //   String? _selectedMarket;
// //   String? _selectedCommodity;
// //   DateTime _selectedDate = DateTime.now();
// //   double _expectedPrice = 0.0;…
// // [12:50 am, 12/12/2024] Devashish Cse: hi
// // [7:55 am, 12/12/2024] Devashish Cse:

//  import 'package:drop_down_list/model/selected_list_item.dart';

// import 'package:flutter/material.dart';
// import 'package:drop_down_list/drop_down_list.dart';
// import 'package:krishfarm/data/hada_state-dis.dart'; // Import the drop_down_list package



// class CropProductionScreen extends StatefulWidget {
//   @override
//   _CropProductionScreenState createState() => _CropProductionScreenState();
// }

// class _CropProductionScreenState extends State<CropProductionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _state = '';
//   String _district = '';
//   String _cropYear = '';
//   String _season = '';
//   String _cropName = '';
//   String _area = '';
//   String _cropProduction = ''; // Placeholder for output

//   List<String> _selectedStates = [];
//   List<String> _selectedSeasons = [];
//   List<String> _selectedDistricts = [];
//   List<String> _cropsAndFruits =
//       cropsAndFruits; // Assuming cropsAndFruits is defined in hada_state-dis.dart

//   // Predefined options for State and Season of Crop
//   List<String> _states = stateDistrictMap.keys.toList();

//   List<String> _seasons = [
//     'Kharif',
//     'Whole Year',
//     'Autumn',
//     'Rabi',
//     'Summer',
//     'Winter'
//   ];

//   String? _selectedSeason; // Use null safety

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Crop Production Estimator'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // State Dropdown
//                 SizedBox(
//                   width: double.infinity, // Make the dropdown full width
//                   child: OutlinedButton(
//                     onPressed: () {
//                       DropDownState(
//                         DropDown(
//                           bottomSheetTitle: const Text(
//                             'Select State',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                             ),
//                           ),
//                           submitButtonChild: const Text(
//                             'Done',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           data: _states
//                               .map((state) => SelectedListItem(name: state))
//                               .toList(),
//                           onSelected: (List<dynamic> selectedList) {
//                             List<String> list = [];
//                             for (var item in selectedList) {
//                               if (item is SelectedListItem) {
//                                 // print("for state $item");
//                                 list.add(item.name);
//                               }
//                             }
//                             setState(() {
//                               _selectedStates = list; // Update selected states
//                               _state = list.isNotEmpty
//                                   ? list.first
//                                   : ''; // Set the first selected state
//                               _selectedDistricts = stateDistrictMap[_state] ??
//                                   []; // Update districts based on selected state
//                               _district =
//                                   ''; // Reset district when state changes
//                             });
//                           },
//                           enableMultipleSelection: false,
//                         ),
//                       ).showModal(context);
//                     },
//                     child: Text(_state.isEmpty
//                         ? 'Select State'
//                         : _state), // Show selected state
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // District Dropdown
//                 SizedBox(
//                   width: double.infinity, // Make the dropdown full width
//                   child: OutlinedButton(
//                     onPressed: () {
//                       if (_state.isEmpty) {
//                         // Show a message if no state is selected
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text('Please select a state first')),
//                         );
//                         return;
//                       }
//                       DropDownState(
//                         DropDown(
//                           bottomSheetTitle: const Text(
//                             'Select District',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                             ),
//                           ),
//                           submitButtonChild: const Text(
//                             'Done',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           data: _selectedDistricts
//                               .map((district) =>
//                                   SelectedListItem(name: district))
//                               .toList(),
//                           onSelected: (List<dynamic> selectedList) {
//                             // print("selectedList $selectedList");
//                             List<String> list = [];
//                             for (var item in selectedList) {
//                               if (item is SelectedListItem) {
//                                 list.add(item.name);
//                               }
//                             }
//                             setState(() {
//                               _district = list.isNotEmpty
//                                   ? list.first
//                                   : ''; // Set the first selected district
//                             });
//                           },
//                           enableMultipleSelection: false,
//                         ),
//                       ).showModal(context);
//                     },
//                     child: Text(_district.isEmpty
//                         ? 'Select District'
//                         : _district), // Show selected district
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Crop Name Dropdown
//                 SizedBox(
//                   width: double.infinity, // Make the dropdown full width
//                   child: OutlinedButton(
//                     onPressed: () {
//                       DropDownState(
//                         DropDown(
//                           bottomSheetTitle: const Text(
//                             'Select Crop',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                             ),
//                           ),
//                           submitButtonChild: const Text(
//                             'Done',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           data: _cropsAndFruits
//                               .map((crop) => SelectedListItem(name: crop))
//                               .toList(),
//                           onSelected: (List<dynamic> selectedList) {
//                             List<String> list = [];
//                             for (var item in selectedList) {
//                               if (item is SelectedListItem) {
//                                 list.add(item.name);
//                               }
//                             }
//                             setState(() {
//                               _cropName = list.isNotEmpty
//                                   ? list.first
//                                   : ''; // Set the first selected crop
//                             });
//                           },
//                           enableMultipleSelection: false,
//                         ),
//                       ).showModal(context);
//                     },
//                     child: Text(_cropName.isEmpty
//                         ? 'Select Crop'
//                         : _cropName), // Show selected crop
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Crop Year
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Crop Year',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter Crop Year';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) => _cropYear = value!,
//                 ),
//                 SizedBox(height: 16),

//                 // Season Dropdown
//                 OutlinedButton(
//                   onPressed: () {
//                     DropDownState(
//                       DropDown(
//                         bottomSheetTitle: const Text(
//                           'Select Season',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20.0,
//                           ),
//                         ),
//                         submitButtonChild: const Text(
//                           'Done',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         data: _seasons
//                             .map((season) => SelectedListItem(name: season))
//                             .toList(),
//                         onSelected: (List<dynamic> selectedList) {
//                           List<String> list = [];
//                           for (var item in selectedList) {
//                             if (item is SelectedListItem) {
//                               list.add(item.name);
//                             }
//                           }
//                           setState(() {
//                             _selectedSeasons = list; // Update selected seasons
//                             _selectedSeason = list.isNotEmpty
//                                 ? list.first
//                                 : ''; // Set the first selected season
//                           });
//                         },
//                         enableMultipleSelection:
//                             false, // Set to true if you want multiple selection
//                       ),
//                     ).showModal(context);
//                   },
//                   child: Text('Select Season'),
//                 ),
//                 SizedBox(height: 16),

//                 // Area (Size of Land)
//                 TextFormField(
//                   decoration: InputDecoration(
//                     labelText: 'Area (in hectares)',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter Area';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) => _area = value!,
//                 ),
//                 SizedBox(height: 24),

//                 // Submit Button
//                 SizedBox(
//                   width: double.infinity, // Make the button full width
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         _formKey.currentState!.save();
//                         // Calculate crop production (example logic)
//                         _cropProduction =
//                             calculateCropProduction(_area, _selectedSeason);
//                         // Show result in a dialog
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return AlertDialog(
//                               title: Text('Crop Production Result'),
//                               content:
//                                   Text('Estimated Production: $_cropProduction'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: Text('OK'),
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       }
//                       // Log the selected details
//                       print('Selected State: $_state');
//                       print('Selected District: $_district');
//                       print('Selected Crop: $_cropName');
//                       // You can also show a message to the user if needed
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Details logged to console')),
//                       );
//                     },
//                     child: Text('Submit'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to calculate crop production
//   String calculateCropProduction(String area, String? season) {
//     // Example calculation logic (this can be modified as needed)
//     double areaInHectares = double.tryParse(area) ?? 0;
//     double productionPerHectare = (season == 'Kharif')
//         ? 2000
//         : (season == 'Rabi')
//             ? 3000
//             : 1500; // Example values
//     double totalProduction = areaInHectares * productionPerHectare;
//     return totalProduction.toStringAsFixed(2) +
//         ' kg'; // Return production in kg
//   }}
// }