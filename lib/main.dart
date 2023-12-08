import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'DeLong Mobile App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CountryClient countryClient = CountryClient();
  final LocalDataService localDataService =
      LocalDataService(); // Added LocalDataService

  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<dynamic>?>? _countriesFuture;
  bool _isLoading = false;
  bool _isLoggedIn = false; // Flag to track user login status
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Simulate authentication with hardcoded credentials
    if (username == 'admin' && password == 'Password1') {
      await widget.localDataService.saveCredentials(username, password);
      setState(() {
        _isLoggedIn = true;
      });
      _loadData(); // Load country data only if logged in
    } else {
      // Show a snackbar indicating login failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final countries = await widget.countryClient.getAllCountries();
      setState(() {
        _isLoading = false;
        _countriesFuture = Future.value(countries);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _countriesFuture = null; // Set countriesFuture to null on error
      });
    }
  }

  void _logout() async {
    await widget.localDataService.clearCredentials();
    setState(() {
      _isLoggedIn = false;
      _countriesFuture = null; // Clear country data on logout
    });
  }

  void _navigateToAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // Show different actions based on login status
          _isLoggedIn
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _logout,
                )
              : IconButton(
                  icon: Icon(Icons.login),
                  onPressed: _login,
                ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? CircularProgressIndicator()
                : _isLoggedIn
                    ? FutureBuilder<List<dynamic>?>(
                        future: _countriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError || snapshot.data == null) {
                            return Text('Error: Failed to load countries');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          final countries = snapshot.data as List<dynamic>?;
                          if (countries!.isEmpty) {
                            return Text('No data available');
                          }

                          return ListView.builder(
                            itemCount: countries.length,
                            itemBuilder: (context, index) {
                              final country = countries[index];
                              return ListTile(
                                title: Text(country['name']['common']),
                                // Add more details or customize the ListTile as needed
                              );
                            },
                          );
                        },
                      )
                    : Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              controller: _usernameController,
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              child: Text('Login'),
                            ),
                          ],
                        ),
                      ),
          ),
          if (!_isLoggedIn)
            Positioned(
              bottom: 8.0,
              left: 8.0,
              child: ElevatedButton(
                onPressed: _navigateToAboutPage,
                child: Text('About'),
              ),
            ),
          // Display version number in the bottom right corner
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: Text(
              'Version 1.0', // Replace 'Version 1.0' with your desired version number
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REST Countries API Information',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'The REST Countries API provides information about countries, including details such as name, population, languages, currencies, and more.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
                height:
                    20.0), // Add some space before the additional information
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Developed by Tim DeLong for CMSC 2204',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class LocalDataService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveCredentials(String username, String password) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final username = await _secureStorage.read(key: 'username');
    final password = await _secureStorage.read(key: 'password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await _secureStorage.deleteAll();
  }
}
