import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Weather App',
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String city = 'New York';
  String apiKey = '1837c7a10aa54562b337e3b62eb07b3e';
  String weatherData = '';

  TextEditingController cityController = TextEditingController();

  Widget _getWeatherIcon(String line) {
    if (line.contains('Max')) {
      return Image.asset(
        'assets/tempicon.png', // Replace with the actual path to your max temperature icon
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Min')) {
      return Image.asset(
        'assets/mintempicon.png', // Replace with the actual path to your min temperature icon
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Temperature')) {
      return Image.asset(
        'assets/hot.png', // Replace with the actual path to your generic temperature icon
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Visibility')) {
      return Image.asset(
        'assets/visabilityicon.png', // Replace with the actual path to your visibility icon
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Description')) {
      return SizedBox.shrink(); // Hide the icon for the description
    } else if (line.contains('Humidity')) {
      return Image.asset(
        'assets/humidityicon.png',
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Pressure')) {
      return Image.asset(
        'assets/pressureicon.png',
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else if (line.contains('Wind Speed')) {
      return Image.asset(
        'assets/windicon.png',
        width: 30,
        height: 30,
        color: Colors.white,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  List<Widget> _buildWeatherWidgets() {
    List<Widget> weatherWidgets = [];
    if (weatherData.isNotEmpty) {
      List<String> lines = weatherData.split('\n');
      for (String line in lines) {
        if (line.isNotEmpty &&
            !line.contains('Description') &&
            !line.contains('Position') &&
            !line.contains('Color')) {
          // Extract only the text (remove unnecessary details and description of icons)
          List<String> parts = line.split(':');
          if (parts.length == 2) {
            String key = parts[0].trim();
            String value = parts[1].trim();

            weatherWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$key: $value',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _getWeatherIcon(line),
                  ),
                ],
              ),
            ));
          }
        }
      }
    }
    return weatherWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CurrentWeather',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  // Set text color to white
                  hintStyle: TextStyle(color: Colors.white),
                ),
                // Set the cursor color to white
                cursorColor: Colors.white,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    city = cityController.text;
                    fetchWeatherData();
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Get Weather Information',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildWeatherWidgets(),
              ),
              SizedBox(height: 20),
              Text(
                'Last Updated: ${DateTime.now().toString()}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sunnyicon.png',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 16),
              Text(
                'CurrentWeather',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchWeatherData() async {
    final searchResponse = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/find?q=$city&appid=$apiKey&units=metric'),
    );

    if (searchResponse.statusCode == 200) {
      Map<String, dynamic> searchData = jsonDecode(searchResponse.body);

      if (searchData['list'] != null && searchData['list'].isNotEmpty) {
        String cityId = searchData['list'][0]['id'].toString();

        final response = await http.get(
          Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?id=$cityId&appid=$apiKey&units=metric'),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);

          int temperature = data['main']['temp'].round();
          int humidity = data['main']['humidity'];
          int pressure = data['main']['pressure'];
          double windSpeed = data['wind']['speed'];
          int minTemperature = data['main']['temp_min'].round();
          int maxTemperature = data['main']['temp_max'].round();
          int visibility = data['visibility'];
          String description = data['weather'][0]['description'];

          setState(() {
            weatherData = 'Temperature: $temperature°C\n'
                'Description: $description\n'
                'Humidity: $humidity%\n'
                'Pressure: $pressure hPa\n'
                'Wind Speed: $windSpeed m/s\n'
                'Min Temperature: $minTemperature°C\n'
                'Max Temperature: $maxTemperature°C\n'
                'Visibility: $visibility meters';
          });
        } else {
          setState(() {
            weatherData = 'Failed to fetch weather data. Please try again.';
          });
        }
      } else {
        setState(() {
          weatherData = 'City not found. Please enter a valid city name.';
        });
      }
    } else {
      setState(() {
        weatherData = 'Failed to fetch weather data. Please try again.';
      });
    }
  }
}
