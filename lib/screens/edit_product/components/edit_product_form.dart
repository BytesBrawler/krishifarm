import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:krishfarm/components/async_progress_dialog.dart';
import 'package:krishfarm/farmer/screens/CalenderScreen/local_widgets/DateField.dart';
import 'package:krishfarm/farmer/services/CropFieldProvider.dart';
import 'package:krishfarm/models/Product.dart';
import 'package:krishfarm/models/sample.dart';
import 'package:krishfarm/services/database/product_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:krishfarm/services/firestore_files_access/firestore_files_access_service.dart';

class ProductUploadForm extends StatefulWidget {
  final Product? product;
  final String title;

  const ProductUploadForm({super.key, this.product, required this.title});
  @override
  _ProductUploadFormState createState() => _ProductUploadFormState();
}

class _ProductUploadFormState extends State<ProductUploadForm> {
  // Step tracking
  int _currentStep = 0;
  String _startTimeString = "";

  Timestamp? _startTimeStamp;
  void setTimeValues(Timestamp timestamp, String date) {
    _startTimeStamp = timestamp;
    _startTimeString = date;
  }

  // Step 1: Product Type Selection
  ProductType? _selectedProductType;

  // Step 2: Specific Category Selection
  String? _selectedCategory;

  // Step 3: Specific Product Selection
  String? _selectedProduct;

  // Step 4: Product Variety Selection
  String? _selectedVariety;

  // Step 5: Seed Company Selection
  String? _selectedSeedCompany;

  // Step 6: Harvest Date
  DateTime? _harvestDate;

  // Step 7: Grade and Organic Certification
  String? _selectedGrade;
  bool _isOrganic = false;
  List<File> _certificationImages = [];

  // Step 8: Order and Pricing Details
  int? _minimumOrderQuantity;

  int? _quantity;
  // String? _quantityUnit;
  bool _isPriceNegotiable = false;
  bool _isDeliveryAvailable = false;

  // Step 9: Product Images
  List<File> _productImages = [];
  List<String> _productImagesURLS = [];
  List<String> _certificateImagesURL = [];

  // Position? _position;

  double? _predictedPrice;
  double? _price;
  String? _rating;

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _selectedProductType != null;
      case 1:
        return _selectedCategory != null;
      case 2:
        return _selectedProduct != null;
      case 3:
        return _selectedVariety != null;
      case 4:
        return _selectedSeedCompany != null;
      case 5:
        return _harvestDate != null;
      case 6:
        return _selectedGrade != null;
      case 7:
        return _minimumOrderQuantity != null;
      // return _minimumOrderQuantity != null && _price != null;
      case 8:
        return _productImages.isNotEmpty;
      // case 9:
      //   return true; // Review step always valid
      default:
        return true;
    }
  }

  // Helper method to build review sections
  Widget _buildReviewSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title + ':',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _uploadCertificationImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _certificationImages =
          pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  void _uploadProductImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _productImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
        imageFile,
        ProductDatabaseHelper().getPathForProductImage(fileName, 0),
      );

      String? downloadUrl = await showDialog(
        context: context,
        builder: (context) => AsyncProgressDialog(
          imgUploadFuture,
          message: Text("Uploading Image Details"),
        ),
      );

      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
      return null;
    }
  }

  String _getRating() {
    try {
      return "8.5";
    } catch (e) {
      print(e);
      return "0.0"; // Default value in case of an error
    }
  }

  double _getPredictedPossiblePrice() {
    try {
      return 3500.0;
    } catch (e) {
      print(e);
      return 0.0; // Default value in case of an error
    }
  }

  // Formatted string conversion
  static double kgToQuintalString(double kg, {int decimalPlaces = 2}) {
    double quintal = kg / 100;
    print(quintal);
    return quintal;
  }

  void _submitProduct(
      // double predictedPrice, double price, String rating
      ) async {
    Position position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print(placemarks);
    String? state = placemarks.first.administrativeArea;
    // String? district = placemarks.first.subAdministrativeArea;

    try {
      //step 1 upload product image
      while (_productImages.isNotEmpty) {
        final imageFile = _productImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _productImagesURLS.add(downloadUrl);
        }
      }

      //step 2 upload certification image
      while (_certificationImages.isNotEmpty) {
        final imageFile = _certificationImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _certificateImagesURL.add(downloadUrl);
        }
      }

      //step 3 submit product
      final product = Product(
        widget.product?.id ?? '',
        name: _selectedProduct!.toLowerCase(),
        category: _selectedCategory!.toLowerCase(),
        variant: _selectedVariety,
        // price: double.parse(price.toString()),
        //  predictivePrice: double.parse(predictedPrice.toString()),
        //  pointRating: double.parse(rating),
        rating: widget.product?.rating ?? 0,
        seed_company: _selectedSeedCompany,

        quantity: kgToQuintalString(_quantity!.toDouble()),
        quantityName: "QN",
        //  phoneNumber: _phoneNumberController.text,
        position: position,
        state: state!.toLowerCase(),
        images: _productImagesURLS,
        productType: _selectedProductType,
        // New fields added
        harvestDate: _harvestDate,
        isOrganic: _isOrganic,
        certificationImages: _certificateImagesURL,
        //  storageMethod: _storageMethodController.text,
        grade: _selectedGrade,
        minimumOrderQuantity:
            kgToQuintalString(_minimumOrderQuantity!.toDouble()),
        // minimumOrderQuantity: int.tryParse(_minimumOrderQuantity.toString()),
        isPriceNegotiable: _isPriceNegotiable,
        isDeliveryAvailable: _isDeliveryAvailable,
      );
      // print(product.productType);
      print(product);

      if (widget.product == null) {
        await ProductDatabaseHelper().addUsersProduct(product);
      } else {
        await ProductDatabaseHelper().updateUsersProduct(product);
      }
      print('Product submitted successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
    // Here you would implement your product submission logic
    // This would involve creating a Product object and saving it to your database
  }

  void _submitCrop(
      // double predictedPrice, double price, String rating
      ) async {
    try {
      //step 1 upload product image
      while (_productImages.isNotEmpty) {
        final imageFile = _productImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _productImagesURLS.add(downloadUrl);
        }
      }

      //step 2 upload certification image
      while (_certificationImages.isNotEmpty) {
        final imageFile = _certificationImages.removeAt(0);
        final downloadUrl = await _uploadImage(imageFile);
        if (downloadUrl != null) {
          _certificateImagesURL.add(downloadUrl);
        }
      }

      //step 3 submit product

      // final product = Product(
      //   widget.product?.id ?? '',
      //   name: _selectedVariety,
      //   category: _selectedCategory,
      //   variant: _selectedVariety,
      //   // price: double.parse(price.toString()),
      //   //  predictivePrice: double.parse(predictedPrice.toString()),
      //   //  pointRating: double.parse(rating),
      //   rating: widget.product?.rating ?? 0,
      //   seed_company: _selectedSeedCompany,
      //   quantity: int.parse(_quantity.toString()),
      //   quantityName: "QN",
      //   //  phoneNumber: _phoneNumberController.text,
      //   position: await Geolocator.getCurrentPosition(),
      //   images: _productImagesURLS,
      //   productType: _selectedProductType,

      //   // New fields added
      //   harvestDate: _harvestDate,
      //   isOrganic: _isOrganic,

      //   certificationImages: _certificateImagesURL,
      //   //  storageMethod: _storageMethodController.text,
      //   grade: _selectedGrade,
      //   minimumOrderQuantity: int.tryParse(_minimumOrderQuantity.toString()),
      //   isPriceNegotiable: _isPriceNegotiable,
      //   isDeliveryAvailable: _isDeliveryAvailable,
      //  );
      // print(product.productType);
      // print(product);

      // if (widget.product == null) {
      //   await ProductDatabaseHelper().addUsersProduct(product);
      // } else {
      //   await ProductDatabaseHelper().updateUsersProduct(product);
      // }
      CropFieldProvider.uploadCropField(
        context: context,
        cropName: _selectedVariety,
        startTimestamp: _startTimeStamp,
        startDate: _startTimeString,
        position: await Geolocator.getCurrentPosition(),
        imageUrl: _productImagesURLS[0],
      );
      print('Product submitted successfully!');
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    }
    // Here you would implement your product submission logic
    // This would involve creating a Product object and saving it to your database
  }

  // Add a method to get a formatted string for various fields
  String _getFormattedValue(dynamic value) {
    if (value == null) return 'Not Selected';
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _currentStep > 0 ? _previousStep : null,
        steps: [
          // Step 1: Product Type
          Step(
            title: Text('Select Product Type'),
            content: DropdownButtonFormField<ProductType>(
              value: _selectedProductType,
              items: ProductType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(EnumToString.convertToString(type)),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedProductType = value;
                print(value);
                _selectedCategory = null;
                _selectedProduct = null;
                _selectedVariety = null;
              }),
              decoration: InputDecoration(
                labelText: 'Product Type',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Step 2: Category Selection
          Step(
            title: Text('Select Category'),
            content: _selectedProductType != null
                ? DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: productCategories[_selectedProductType]!
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategory = value;
                      _selectedProduct = null;
                      _selectedVariety = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a product type first'),
          ),

          // Step 3: Product Selection
          Step(
            title: Text('Select Product'),
            content: _selectedCategory != null
                ? DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    items: categoryProducts[_selectedCategory]!
                        .map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedProduct = value;
                      _selectedVariety = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a category first'),
          ),

          // Step 4: Variety Selection
          Step(
            title: Text('Select Variety'),
            content: _selectedProduct != null
                ? DropdownButtonFormField<String>(
                    value: _selectedVariety,
                    items: productVarieties[_selectedProduct]!
                        .map((variety) => DropdownMenuItem(
                              value: variety,
                              child: Text(variety),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedVariety = value;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Variety',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text('Please select a product first'),
          ),

          // Step 5: Seed Company Selection
          Step(
            title: Text('Select Seed Company'),
            content: DropdownButtonFormField<String>(
              value: _selectedSeedCompany,
              items: seedCompanies
                  .map((company) => DropdownMenuItem(
                        value: company,
                        child: Text(company),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedSeedCompany = value;
              }),
              decoration: InputDecoration(
                labelText: 'Seed Company',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Step(
          //   title: Text('Select Sowing date'),
          //   content: DateField(setTimeValues, true),
          // ),

          // Step 6: Harvest Date
          Step(
            title: Text(widget.title == "Add Crop"
                ? 'Select Sowing Date'
                : 'Select Harvest Date'),
            content: ListTile(
              title: Text(
                  widget.title == "Add Crop" ? 'Sowing Date' : 'Harvest Date'),
              subtitle: Text(_harvestDate == null
                  ? widget.title == "Add Crop"
                      ? ' Select Sowing Date'
                      : ' Select Harvest Date'
                  : '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _harvestDate = pickedDate;
                  });
                }
              },
            ),
          ),

          // Step 7: Grade and Organic Certification
          Step(
            title: Text('Grade and Certification'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  items: grades
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedGrade = value;
                  }),
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  title: Text('Is Organic?'),
                  value: _isOrganic,
                  onChanged: (bool value) {
                    setState(() {
                      _isOrganic = value;
                    });
                  },
                ),
                if (_isOrganic)
                  ElevatedButton(
                    onPressed: _uploadCertificationImages,
                    child: Text('Upload Organic Certification'),
                  ),
              ],
            ),
          ),

          // Step 8: Order and Pricing Details
          Step(
            title: const Text('Order and Pricing'),
            content: Column(
              children: [
                //
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Total Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _quantity = int.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Minimum Order Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minimumOrderQuantity = int.tryParse(value);
                  },
                ),
                //  SizedBox(height: 16),
                // TextFormField(
                //   decoration: InputDecoration(
                //     labelText: 'Price per Unit',
                //     prefixText: '₹ ',
                //     border: OutlineInputBorder(),
                //   ),
                //   keyboardType: TextInputType.numberWithOptions(decimal: true),
                //   onChanged: (value) {
                //     _price = double.tryParse(value);
                //   },
                // ),

                // Row(
                //   children: [
                //     Expanded(
                //       flex: 2,
                //       child:
                //     ),
                //     SizedBox(width: 16),
                //     Expanded(
                //       child: DropdownButtonFormField<String>(
                //         value: _quantityUnit,
                //         items: quantityUnits
                //             .map((unit) => DropdownMenuItem(
                //                   value: unit,
                //                   child: Text(unit),
                //                 ))
                //             .toList(),
                //         onChanged: (value) => setState(() {
                //           _quantityUnit = value;
                //         }),
                //         decoration: InputDecoration(
                //           labelText: 'Unit',
                //           border: OutlineInputBorder(),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(
                  height: 2,
                ),
                // SwitchListTile(
                //   title: Text('Is Price Negotiable?'),
                //   value: _isPriceNegotaible,
                //   onChanged: (bool value) {
                //     setState(() {
                //       _isPriceNegotaible = value;
                //     });
                //   },
                // ),
                // const SizedBox(
                //   height: 2,
                // ),
                // SwitchListTile(
                //   title: Text('Is Deliverable?'),
                //   value: _isDeliveryAvailable,
                //   onChanged: (bool value) {
                //     setState(() {
                //       _isDeliveryAvailable = value;
                //     });
                //   },
                // ),
              ],
            ),
          ),

          // Step 9: Product Images
          Step(
            title: Text(widget.title == "Add Crop"
                ? 'Upload Crop Field Images'
                : "Upload Product Image"),
            content: Column(
              children: [
                ElevatedButton(
                  onPressed: _uploadProductImages,
                  child: Text(widget.title == "Add Crop"
                      ? 'Upload Crop Field Images'
                      : "Upload Product Image"),
                ),
                const SizedBox(height: 16),
                _productImages.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _productImages.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            _productImages[index],
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Text('No images selected'),
              ],
            ),
          ),
          //   // New Step 9: Review Details
          //   Step(
          //     title: Text('Review Details'),
          //     content: SingleChildScrollView(
          //       child: reviewCard(context),
          //     ),
          //   ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              ElevatedButton(
                onPressed: _currentStep < 8
                    ? details.onStepContinue
                    : () => _showReviewBottomSheet(context),
                child: Text(_currentStep < 8 ? 'Next' : 'Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget reviewCard(BuildContext context, bool isCrop) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewSection(
                'Product Type', _getFormattedValue(_selectedProductType)),
            _buildReviewSection(
                'Category', _getFormattedValue(_selectedCategory)),
            _buildReviewSection(
                'Product', _getFormattedValue(_selectedProduct)),
            _buildReviewSection(
                'Variety', _getFormattedValue(_selectedVariety)),
            _buildReviewSection(
                'Seed Company', _getFormattedValue(_selectedSeedCompany)),
            _buildReviewSection(isCrop ? "Showing date" : 'Harvest Date',
                _getFormattedValue(_harvestDate)),
            _buildReviewSection('Grade', _getFormattedValue(_selectedGrade)),
            _buildReviewSection('Organic', _getFormattedValue(_isOrganic)),
            _buildReviewSection('Minimum Order Quantity',
                _getFormattedValue(_minimumOrderQuantity)),
            // _buildReviewSection(
            //     'Price',
            //     _price != null
            //         ? '₹ ${_price!.toStringAsFixed(2)}'
            //         : 'Not Set'),
            // _buildReviewSection('Quantity',
            //     '${_getFormattedValue(_quantity)} ${_getFormattedValue(_quantityUnit)}'),
            // _buildReviewSection(
            //     'Price Negotiable', _getFormattedValue(_isPriceNegotaible)),
            // _buildReviewSection(
            //     'Delivery Available', _getFormattedValue(_isDeliveryAvailable)),

            // Product Images Preview
            Text(isCrop ? "Crop Field images" : 'Product Images:',
                style: Theme.of(context).textTheme.titleMedium),
            _productImages.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _productImages.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        _productImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Text('No images selected'),
          ],
        ),
      ),
    );
  }

  // Method to show review bottom sheet
  void _showReviewBottomSheet(BuildContext context) {
    bool isReviewStep = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  // Dynamic Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isReviewStep
                          ? 'Review Your Product Details'
                          : 'Confirm Your Pricing',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Conditional Content
                  isReviewStep
                      ? reviewCard(context, widget.title == "Add Crop")
                      : _buildPricingContent(context),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (!isReviewStep)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setModalState(() {
                                  isReviewStep = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              child: Text('Back'),
                            ),
                          ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isReviewStep) {
                                // Move to pricing step
                                setModalState(() {
                                  isReviewStep = false;
                                });
                              } else {
                                // Final submission
                                _submitProduct();
                                //  _confirmAndSubmit(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: Text(isReviewStep
                                ? 'Next: Pricing'
                                : 'Confirm and Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build Pricing Content
  Widget _buildPricingContent(BuildContext context) {
    // _predictedPrice = _getPredictedPossiblePrice();
    // _rating = _getRating();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Predicted Price Card
          Card(
            elevation: 4,
            color: Colors.teal[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Text(
                  //   'Your Rating is :',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.teal,
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  // Text(
                  //   _rating != null ? _rating! : 'rating Not Available',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.teal[700],
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  // SizedBox(height: 10),
                  Text(
                    'Thank you for providing the product details!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Text(
                  //   _predictedPrice != null
                  //       ? '₹ ${_predictedPrice!.toStringAsFixed(2)}'
                  //       : 'Price Not Available',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.teal[700],
                  //   ),
                  // ),
                  // SizedBox(height: 8),
                  Text(
                    'This you will get price based on market trends and your product details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.teal[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
