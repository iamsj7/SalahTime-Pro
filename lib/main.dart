import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

void main() {
  tz.initializeTimeZones();
  final timezone = tz.getLocation('Asia/Muscat');

  runApp(MyApp(timezone: timezone));
}

class MyApp extends StatelessWidget {
  final tz.Location timezone;

  MyApp({
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PrayerTimesScreen(timezone: timezone),
    );
  }
}

class PrayerTimesScreen extends StatefulWidget {
  final tz.Location timezone;

  PrayerTimesScreen({
    required this.timezone,
  });

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late PrayerTimes _prayerTimes;
  String? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
    _getUserLocationAndUpdatePrayerTimes();
  }

  void _initializePrayerTimes() {
    Coordinates coordinates =
        Coordinates(23.5999431, 58.3901939); // Muscat, Oman coordinates

    CalculationParameters params = CalculationMethod.Dubai();
    params.madhab = Madhab.Shafi;
    _prayerTimes =
        PrayerTimes(coordinates, DateTime.now(), params, precision: true);
  }

  Future<void> _getUserLocationAndUpdatePrayerTimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (position != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          setState(() {
            _userLocation = '${placemark.locality}, ${placemark.country}';
          });
        }
        final coordinates = Coordinates(position.latitude, position.longitude);
        CalculationParameters params = CalculationMethod.Dubai();
        params.madhab = Madhab.Shafi;
        _prayerTimes =
            PrayerTimes(coordinates, DateTime.now(), params, precision: true);
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  Future<void> _refreshPrayerTimes() async {
    await _getUserLocationAndUpdatePrayerTimes();
    // You may want to add a loading indicator here while fetching data.
  }

  @override
  Widget build(BuildContext context) {
    final now = tz.TZDateTime.now(widget.timezone);
    final formattedCurrentDateTime =
        DateFormat('MMMM d, y - h:mm a').format(now);

    final currentPrayer = _prayerTimes.currentPrayer(date: DateTime.now());
    final nextPrayer = _prayerTimes.nextPrayer();
    final nextPrayerTime = _prayerTimes.timeForPrayer(nextPrayer);

    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPrayerTimes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPrayerTimes,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Current Date and Time:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  subtitle: Text(
                    formattedCurrentDateTime,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                Divider(),
                if (_userLocation != null)
                  ListTile(
                    title: Text(
                      'User Location:',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    subtitle: Text(
                      _userLocation!,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                Divider(),
                PrayerTimeCard(
                  prayerName: 'Fajr',
                  prayerTime: _formatTime(_prayerTimes.fajr, widget.timezone),
                ),
                PrayerTimeCard(
                  prayerName: 'Sunrise',
                  prayerTime:
                      _formatTime(_prayerTimes.sunrise, widget.timezone),
                ),
                PrayerTimeCard(
                  prayerName: 'Dhuhr',
                  prayerTime: _formatTime(_prayerTimes.dhuhr, widget.timezone),
                ),
                PrayerTimeCard(
                  prayerName: 'Asr',
                  prayerTime: _formatTime(_prayerTimes.asr, widget.timezone),
                ),
                PrayerTimeCard(
                  prayerName: 'Maghrib',
                  prayerTime:
                      _formatTime(_prayerTimes.maghrib, widget.timezone),
                ),
                PrayerTimeCard(
                  prayerName: 'Isha',
                  prayerTime: _formatTime(_prayerTimes.isha, widget.timezone),
                ),
                Divider(),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      'Current Prayer',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    ),
                    subtitle: Text(
                      currentPrayer,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      'Next Prayer',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    ),
                    subtitle: Text(
                      nextPrayer,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      'Time for Next Prayer',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    ),
                    subtitle: Text(
                      _formatTime(nextPrayerTime, widget.timezone),
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? time, tz.Location timezone) {
    if (time == null) {
      return 'N/A';
    }
    final formattedTime = tz.TZDateTime.from(time, timezone);
    return DateFormat('h:mm a').format(formattedTime);
  }
}

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;

  PrayerTimeCard({required this.prayerName, required this.prayerTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: ListTile(
          leading: Icon(Icons.access_alarm, color: Colors.white),
          title: Text(
            prayerName,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          subtitle: Text(
            prayerTime,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
