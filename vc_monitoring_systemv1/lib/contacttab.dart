import 'package:flutter/material.dart';

class contacttab extends StatelessWidget {
  const contacttab({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {
        'name': 'Jhun Harvey Cueto',
        'email': 'jhunharveycueto@gmail.com',
        'phone': '09123450400',
        'role': 'Main Developer',
        'description':
            'Leads the development of the VermiApp, handling the app’s design, features, and overall system integration.',
      },
      {
        'name': 'Sean Angelo Gumba',
        'email': 'gumbaseanangelo@gmail.com',
        'phone': '09694568025',
        'role': 'IoT Manager',
        'description':
            'Responsible for configuring and managing the IoT system, including sensors, automation, and real-time monitoring.',
      },
      {
        'name': 'Timoteo Bien Mendoza',
        'email': 'bientimoteo@gmail.com',
        'phone': '09278259364',
        'role': 'Structural Builder',
        'description':
            'In charge of building and maintaining the physical structure that houses the IoT components, ensuring stability and functionality.',
      },
    ];

    return Container(
      color: Colors.green[50], // ✅ Set background color here
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final person = contacts[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 30, color: Colors.green),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person['name']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            person['role']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    person['description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text('Email: ${person['email']}'),
                  Text('Phone: ${person['phone']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
