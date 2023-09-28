import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

void main() {
  tz.initializeTimeZones();
  final timezone = tz.getLocation('Asia/Muscat');
  Coordinates coordinates =
      Coordinates(23.5999431, 58.3901939); // Muscat, Oman coordinates

  CalculationParameters params = CalculationMethod.Dubai();
  params.madhab = Madhab.Shafi;
  PrayerTimes prayerTimes =
      PrayerTimes(coordinates, DateTime.now(), params, precision: true);

  runApp(MyApp(
    prayerTimes: prayerTimes,
    timezone: timezone,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final tz.Location timezone;

  MyApp({
    required this.prayerTimes,
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PrayerTimesScreen(prayerTimes, timezone),
      },
    );
  }
}

class PrayerTimesScreen extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final tz.Location timezone;

  PrayerTimesScreen(this.prayerTimes, this.timezone);

  @override
  Widget build(BuildContext context) {
    final now = tz.TZDateTime.now(timezone);
    final formattedCurrentDateTime =
        DateFormat('MMMM d, y - h:mm a').format(now);

    final currentPrayer = prayerTimes.currentPrayer(date: DateTime.now());
    final nextPrayer = prayerTimes.nextPrayer();
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);

    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
      ),
      body: SingleChildScrollView(
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
              PrayerTimeCard(
                prayerName: 'Fajr',
                prayerTime: _formatTime(prayerTimes.fajr, timezone),
              ),
              PrayerTimeCard(
                prayerName: 'Sunrise',
                prayerTime: _formatTime(prayerTimes.sunrise, timezone),
              ),
              PrayerTimeCard(
                prayerName: 'Dhuhr',
                prayerTime: _formatTime(prayerTimes.dhuhr, timezone),
              ),
              PrayerTimeCard(
                prayerName: 'Asr',
                prayerTime: _formatTime(prayerTimes.asr, timezone),
              ),
              PrayerTimeCard(
                prayerName: 'Maghrib',
                prayerTime: _formatTime(prayerTimes.maghrib, timezone),
              ),
              PrayerTimeCard(
                prayerName: 'Isha',
                prayerTime: _formatTime(prayerTimes.isha, timezone),
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
                    _formatTime(nextPrayerTime, timezone),
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}
