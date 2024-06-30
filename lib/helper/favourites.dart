import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final Set<String> favoriteContactIds;

  FavoritesPage({required this.favoriteContactIds});

  @override
  Widget build(BuildContext context) {
    List<Contact> favoriteContacts = [];
    // Populate favoriteContacts based on favoriteContactIds
    // You may need to fetch contact details using the contact identifier

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: favoriteContacts.isEmpty
          ? Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: favoriteContacts.length,
              itemBuilder: (context, index) {
                Contact contact = favoriteContacts[index];
                String displayName = contact.displayName ?? 'No Name';
                String timeZoneId = ''; // Get timeZoneId based on contact identifier
                String currentTime = ''; // Get current time using timezoneHelper
                String currentDate = ''; // Get current date using timezoneHelper
                String timeZoneAbbr = ''; // Get timeZone abbreviation using timezoneHelper

                return ListTile(
                  title: Text(displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentDate),
                      Text(currentTime),
                    ],
                  ),
                  trailing: Text(timeZoneAbbr),
                );
              },
            ),
    );
  }
}
