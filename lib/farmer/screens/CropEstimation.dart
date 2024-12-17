import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:krishfarm/data/hada_state-dis.dart';
import 'package:krishfarm/farmer/screens/areaToolScreen.dart';

class CropProductionScreen extends StatefulWidget {
  final Map map;
  const CropProductionScreen({super.key, required this.map});

  @override
  _CropProductionScreenState createState() => _CropProductionScreenState();
}

class _CropProductionScreenState extends State<CropProductionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field variables
  String _state = '';
  String _district = '';
  String _cropYear = '';
  String _season = '';
  String _cropName = '';
  String _area = '';
  String _estimatedProduction = ''; // To store API response
  bool _isLoading = false;

  // Dropdown lists
  List<String> _states = stateDistrictMap.keys.toList();
  List<String> _seasons = [
    'Kharif',
    'Rabi',
    'Summer',
    'Whole Year',
    'Winter',
    'Autumn'
  ];
  List<String> _cropsAndFruits = cropsAndFruits;
  List<String> _selectedDistricts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Production Estimator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // State Dropdown
              _buildDropdownButton(
                label: 'Select State',
                value: _state.isEmpty ? null : _state,
                items: _states,
                onChanged: (value) {
                  setState(() {
                    _state = value!;
                    _selectedDistricts = stateDistrictMap[_state] ?? [];
                    _district = ''; // Reset district
                  });
                },
              ),

              const SizedBox(height: 16),

              // District Dropdown
              _buildDropdownButton(
                label: 'Select District',
                value: _district.isEmpty ? null : _district,
                items: _selectedDistricts,
                onChanged: (value) {
                  setState(() {
                    _district = value!;
                  });
                },
                enabled: _state.isNotEmpty,
              ),

              const SizedBox(height: 16),

              // Crop Name Dropdown
              _buildDropdownButton(
                label: 'Select Crop',
                value: _cropName.isEmpty ? null : _cropName,
                items: _cropsAndFruits,
                onChanged: (value) {
                  setState(() {
                    _cropName = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Crop Year Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Crop Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Crop Year';
                  }
                  // Optional: Add more robust year validation
                  return null;
                },
                onSaved: (value) => _cropYear = value!,
              ),

              const SizedBox(height: 16),

              // Season Dropdown
              _buildDropdownButton(
                label: 'Select Season',
                value: _season.isEmpty ? null : _season,
                items: _seasons,
                onChanged: (value) {
                  setState(() {
                    _season = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Area Input
              Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Area (in hectares)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.landscape),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Area';
                      }
                      final numValue = double.tryParse(value);
                      if (numValue == null || numValue <= 0) {
                        return 'Please enter a valid area';
                      }
                      return null;
                    },
                    onSaved: (value) => _area = value!,
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Areatoolscreen(),
                          )),
                      child: const Text("calculate area")),
                ],
              ),

              const SizedBox(height: 24),

              // Submit Button
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Estimate Production',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              // Production Result
              if (_estimatedProduction.isNotEmpty) ...[
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Estimated Production',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _estimatedProduction,
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Dropdown Button Builder
  Widget _buildDropdownButton({
    required String label,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? value,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: value,
      hint: Text(label),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please $label';
        }
        return null;
      },
    );
  }

  // Form Submission Method
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
        _estimatedProduction = '';
      });

      try {
        Map data = {
          'State_Name': _state,
          'District_Name': _district,
          'Crop_Year': _cropYear,
          'Season': _season,
          'Crop': _cropName,
          'Area': _area,
        };
        print(data);
        final response = await http.post(
          Uri.parse(
              'https://dcac-103-232-241-223.ngrok-free.app/api/crop-production'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode([data]),
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print(responseData);
          setState(() {
            _estimatedProduction = '${responseData['prediction']} kg';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Production estimated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to estimate production');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
