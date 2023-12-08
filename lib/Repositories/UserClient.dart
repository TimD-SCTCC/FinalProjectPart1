import 'dart:convert';
import 'dart:io';

class CountryClient {
  Future<List<dynamic>?> getAllCountries() async {
    try {
      final uri = Uri.parse('https://restcountries.com/v3.1/all');
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API');
    }
  }
}
