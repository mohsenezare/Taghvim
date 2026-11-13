import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart' as intl;

// سرویس مدیریت اعلان‌ها و صوت اذان
class AzanNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        stopAzan();
      },
    );
  }

  // نمایش نوتیفیکیشن و پخش همزمان اذان
  static Future<void> showAzanNotification(String prayerName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'azan_channel_id',
      'پخش اذان و اوقات شرعی',
      channelDescription: 'اعلان اوقات شرعی و پخش خودکار اذان',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      'هنگامه $prayerName',
      'الله اکبر... وقت شرعی $prayerName فرا رسیده است.',
      platformChannelSpecifics,
    );

    await playAzanAudio();
  }

  static Future<void> playAzanAudio() async {
    try {
      // فایل صوتی نمونه (می‌توانید لینک فایل صوتی اذان دلخواه یا فایل لوکال قرار دهید)
      await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
    } catch (e) {
      debugPrint('خطا در پخش صوت اذان: $e');
    }
  }

  static Future<void> stopAzan() async {
    await _audioPlayer.stop();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AzanNotificationService.init();
  runApp(const DoTaskAzanApp());
}

class DoTaskAzanApp extends StatelessWidget {
  const DoTaskAzanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تقویم، کارها و اذان‌گو',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CalendarScreen(),
    const TodoScreen(),
    const AzanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'تقویم',
            ),
          

  NavigationDestination(
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task),
              label: 'کارها',
            ),
            NavigationDestination(
              icon: Icon(Icons.volume_up_outlined),
              selectedIcon: Icon(Icons.volume_up),
              label: 'اذان‌گو',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۱. صفحه تقویم شمسی ====================
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Jalali.now();
    final formatter = now.formatter;

    return Scaffold(
      appBar: AppBar(title: const Text('تقویم روزانه')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${formatter.weekDay.name}, ${formatter.day} ${formatter.monthName} ${formatter.year}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'امروز روز پربار و عالی برای پیشبرد اهدافتان است.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ۲. صفحه کارهای روزانه (To-Do) ====================
class TaskItem {
  String title;
  bool isCompleted;
  TaskItem({required this.title, this.isCompleted = false});
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<TaskItem> _tasks = [
    TaskItem(title: 'بررسی پروژه‌های گیت‌هاب', isCompleted: true),
    TaskItem(title: 'توسعه ماژول اوقات شرعی'),
    TaskItem(title: 'تنظیم تست‌های پلتفرم اندروید'),
  ];
  
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(TaskItem(title: _controller.text));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کارهای روزانه')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'عنوان کار جدید...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    set

State(() {
                      task.isCompleted = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ۳. صفحه اوقات شرعی و اذان‌گوی هوشمند ====================
class AzanScreen extends StatefulWidget {
  const AzanScreen({super.key});

  @override
  State<AzanScreen> createState() => _AzanScreenState();
}

class _AzanScreenState extends State<AzanScreen> {
  bool _isLoading = true;
  String _locationStatus = 'در حال دریافت موقعیت مکانی (GPS)...';
  Map<String, String> prayerTimesMap = {};

  @override
  void initState() {
    super.initState();
    _determinePositionAndCalculateTimes();
  }

  Future<void> _determinePositionAndCalculateTimes() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'GPS خاموش است. استفاده از مختصات پیش‌فرض تهران';
          _loadDefaultTehranTimes();
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'دسترسی به مکان داده نشد. پیش‌فرض تهران';
            _loadDefaultTehranTimes();
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      _calculatePrayerTimes(position.latitude, position.longitude);
      
    } catch (e) {
      setState(() {
        _locationStatus = 'خطا در دریافت GPS. استفاده از پیش‌فرض تهران';
        _loadDefaultTehranTimes();
      });
    }
  }

  void _calculatePrayerTimes(double lat, double lng) {
    final coordinates = adhan.Coordinates(lat, lng);
    final params = adhan.CalculationMethod.tehran.getParameters();
    params.madhab = adhan.Madhab.hanafi;

    final date = DateTime.now();
    final prayerTimes = adhan.PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    final formatter = intl.DateFormat('HH:mm');

    setState(() {
      prayerTimesMap = {
        'اذان صبح': formatter.format(prayerTimes.fajr!),
        'طلوع آفتاب': formatter.format(prayerTimes.sunrise!),
        'اذان ظهر': formatter.format(prayerTimes.dhuhr!),
        'غروب آفتاب': formatter.format(prayerTimes.sunset!),
        'اذان مغرب': formatter.format(prayerTimes.maghrib!),
        'عشا': formatter.format(prayerTimes.isha!),
      };
      _locationStatus = 'موقعیت شما با موفقیت شناسایی و اوقات شرعی محاسبه شد.';
      _isLoading = false;
    });
  }

  void _loadDefaultTehranTimes() {
    _calculatePrayerTimes(35.6892, 51.3890);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اوقات شرعی و اذان‌گو')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('وضعیت سیستم:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_locationStatus, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active, size: 36),
                      onPressed: ()

 {
                        // تست دستی اعلان و پخش اذان
                        AzanNotificationService.showAzanNotification('تست اذان');
                      },
                      tooltip: 'تست اعلان و پخش اذان',
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: ListView(
                      children: prayerTimesMap.entries.map((entry) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.access_time_filled, color: Colors.blue),
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text(entry.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
