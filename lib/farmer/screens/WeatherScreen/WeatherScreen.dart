import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:krishfarm/basic_utitlities.dart';
import 'package:krishfarm/data/Repository.dart';
import 'package:krishfarm/data/api_exception.dart';
import 'package:krishfarm/farmer/screens/WeatherScreen/local_widgets/prediction.dart';
import 'package:krishfarm/models/Product.dart';
import 'package:krishfarm/services/database/product_database_helper.dart';
import 'package:provider/provider.dart';

import './state/WeatherBloc.dart';
import './state/WeatherState.dart';
import './local_widgets/Temperature.dart';
import './local_widgets/Forecasts.dart';
import './local_widgets/MiscWeather.dart';
import '../../widgets/LoadingSpinner.dart';
import './local_widgets/WeatherAppBar.dart';
import '../../services/LocalizationProvider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  ApiRepo _api = ApiRepo();

  Map<String, dynamic> prediction = {
    "January": 0.0,
    "February": 0.0,
    "March": 0.0,
    "April": 0.0,
    "May": 0.0,
    "June": 0.0,
    "July": 0.0,
    "August": 0.0,
    "September": 0.0,
    "October": 0.0,
    "November": 0.0,
    "December": 0.0,
  };

  @override
  void initState() {
    super.initState();
    getFunction();
    setState(() {});
  }

  void getFunction() async {
    print("Getting prediction");
    prediction = await _rainfallAi();
  }

  Future<Map<String, dynamic>> _rainfallAi() async {
    print("Getting location");
    try {
      Position position = await ProductDatabaseHelper().determinePosition();
      // Position position = await ProductDatabaseHelper().userLocation();

      double lat = position.latitude;

      double long = position.longitude;
      print(position);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      print(placemarks);
      String? state = placemarks.first.administrativeArea;
      String? district = placemarks.first.subAdministrativeArea;

      List data = [
        {
          "STATE_UT_NAME": state,
          "DISTRICT": district,
          "lat": lat,
          "longs": long
        }
      ];
      print(data);
      final response = await _api.rainfallAi(data);
      print("Response is $response");
      dynamic pre = arrangeMapFromCurrentMonth(response["prediction"]);
      setState(() {});
      // setState(() {
      //   prediction = response["data"];
      // });
      return pre;

      //   Utils.snackBar(context, response["message"]); // Display OTP sent message
    } on ApiException catch (errorJson) {
      final errorMessage = errorJson.message;
      print(errorMessage);

      ///  Utils.snackBar(context, errorMessage);
    } catch (error) {
      print(error);
      //  Utils.snackBar(context, "An unexpected error occurred. $error");
      return {};
    }
    return {};
  }

  Map<String, double> arrangeMapFromCurrentMonth(
      Map<String, dynamic> inputMap) {
    // Define full month names in order
    final monthOrder = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Get current month
    DateTime now = DateTime.now();
    String currentMonth = monthOrder[now.month - 1];

    // Create a new sorted map starting from current month
    Map<String, double> sortedMap = {};

    // Find the index of current month
    int currentMonthIndex = monthOrder.indexOf(currentMonth);

    // Rearrange months starting from current month
    for (int i = 0; i < monthOrder.length; i++) {
      // Calculate the actual month index in the circular list
      String month = monthOrder[(currentMonthIndex + i) % 12];

      // Add to map if the month exists in input map
      if (inputMap.containsKey(month)) {
        sortedMap[month] = double.parse(inputMap[month].toStringAsFixed(2));
      }
    }

    return sortedMap;
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return StreamBuilder<WeatherState>(
      initialData: WeatherState.onRequest(),
      stream: Provider.of<WeatherBloc>(context).state,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isLoading = state?.isLoading ?? true;

        return Scaffold(
          appBar: weatherAppBar(context, isEnglish, state!),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: isLoading
                  ? Center(child: loadingSpinner())
                  : Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            isEnglish
                                ? "5 Day Forecast"
                                : "5 दिन का पूर्वानुमान",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 20,
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        forecasts(isEnglish, context, state!),
                        SizedBox(height: 20),
                        temperature(isEnglish, state),
                        SizedBox(height: 40),
                        miscWeather(isEnglish, state),
                        SizedBox(height: 20),
                        predictionDisplay(prediction)
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
