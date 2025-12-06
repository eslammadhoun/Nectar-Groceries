import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nectar/V2/Data/services/location_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final geoApiKey = dotenv.env['GEO_API_KEY'];
  static const geoApiBaseUrl = 'https://api.geoapify.com/v1/geocode';
  static final countryStateCityApiKey = dotenv.env['COUNTRY_API_KEY'];
  static final countryStateCityBaseUrl =
      'https://api.countrystatecity.in/v1/countries/';

  // get user country from enterd lat & long
  static Future<String?> getUserCountry() async {
    try {
      final Position? pos = await LocationService.getLatLong();
      if (pos == null) return null;

      final url =
          '$geoApiBaseUrl/reverse?lat=${pos.latitude}&lon=${pos.longitude}&apiKey=$geoApiKey';
      final getResponse = await http.get(Uri.parse(url));
      if (getResponse.statusCode == 200) {
        return jsonDecode(
          getResponse.body,
        )['features'][0]['properties']['country_code'];
      }
      return null;
    } catch (e) {
      print("Error Getting user Country: $e");
      return null;
    }
  }

  // get All Country Cities from it's Country Name
  static Future<List<Map<String, dynamic>>?> getCountryCities(
    String? countryName,
  ) async {
    final String url = '$countryStateCityBaseUrl$countryName/states';

    final getResponse = await http.get(
      Uri.parse(url),
      headers: {'X-CSCAPI-KEY': countryStateCityApiKey!},
    );
    if (getResponse.statusCode == 200) {
      final List<dynamic> cities = jsonDecode(getResponse.body);
      List<Map<String, dynamic>> listOfCities = List<Map<String, dynamic>>.from(
        cities,
      );
      return listOfCities;
    } else {
      return null;
    }
  }
}
