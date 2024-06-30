import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:time_zone/helper/timezone_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TimezoneHelper timezoneHelper = TimezoneHelper();
  await timezoneHelper.loadTimezones(); // Load the time zones
  runApp(MyApp(timezoneHelper: timezoneHelper));
}

class MyApp extends StatelessWidget {
  final TimezoneHelper timezoneHelper;

  MyApp({required this.timezoneHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactListPage(timezoneHelper: timezoneHelper),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ContactListPage extends StatefulWidget {
  final TimezoneHelper timezoneHelper;

  ContactListPage({required this.timezoneHelper});

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  Map<String, String> contactTimeZones = {};
  TextEditingController searchController = TextEditingController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    searchController.addListener(filterContacts);
    _startTimer();
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Future<void> requestPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      fetchContacts();
    } else {
      // Handle the case when permission is not granted
    }
  }

 Future<void> fetchContacts() async {
  try {
    Iterable<Contact> _contacts = await ContactsService.getContacts();
    setState(() {
      contacts = _contacts.toList();
      filteredContacts = contacts;
    });
    for (var contact in contacts) {
      if (contact.phones!.isNotEmpty) {
        String phoneNumber = contact.phones!.first.value!;
        try {
          String formattedNumber = await formatPhoneNumber(phoneNumber);
          PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(formattedNumber);
          String? countryCode;
          if (number.isoCode != null) {
            countryCode = number.isoCode!;
            String timeZoneId = widget.timezoneHelper.getTimeZoneId(countryCode);
            setState(() {
              contactTimeZones[contact.displayName ?? 'No Name'] = timeZoneId;
            });
          } else {
            print('ISO code is null for phone number: $formattedNumber');
            // Handle the case where isoCode is null if needed
          }
        } catch (e) {
          print("Error parsing phone number: $e");
        }
      }
    }
  } catch (e) {
    print("Error fetching contacts: $e");
  }
}


  Future<String> formatPhoneNumber(String phoneNumber) async {
    if (phoneNumber.startsWith('0')) {
      return '+92' + phoneNumber.substring(1); // Adjust for Pakistan; customize for other countries if needed
    }
    return phoneNumber;
  }

  void filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        String displayName = contact.displayName?.toLowerCase() ?? '';
        String phoneNumber = contact.phones!.isNotEmpty ? contact.phones!.first.value!.toLowerCase() : '';
        return displayName.contains(query) || phoneNumber.contains(query);
      }).toList();
    });
  }

  Color _getBackgroundColor(int index) {
    // You can add more colors if needed
    List<Color> colors = [Colors.pink, Colors.purple, Colors.deepPurple];
    return colors[index % colors.length];
  }

  void _launchCaller(String number) async {
    String url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make Scaffold background transparent
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(144, 49, 49, 49),
            title: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Contacts',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white),
                icon: Icon(Icons.search, color: Colors.black),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstATop),
            child: Image.asset(
              'assets/clocksbg.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          filteredContacts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = filteredContacts[index];
                    String displayName = contact.displayName ?? 'No Name';
                    String timeZoneId = contactTimeZones[displayName] ?? 'UTC';
                    String currentTime = widget.timezoneHelper.getCurrentTime(timeZoneId);
                    String currentDate = widget.timezoneHelper.getCurrentDate(timeZoneId);
                    String timeZoneAbbr = widget.timezoneHelper.getTimeZoneAbbreviation(timeZoneId);
                    String phoneNumber = contact.phones!.isNotEmpty ? contact.phones!.first.value! : '';

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(index),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.phone, color: Colors.white),
                                onPressed: () {
                                  _launchCaller(phoneNumber);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentDate,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeZoneAbbr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                currentTime,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
