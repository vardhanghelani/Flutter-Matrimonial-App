import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  Widget buildInfoCard(String title, List<Map<String, String>> details) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:Color.fromRGBO(107, 203, 217, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${detail["label"]}: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(detail["value"]!),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Color.fromRGBO(107, 203, 217, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/couple-logo-design-illustrations-vector.jpg'), // Change to your image asset
            ),
            const SizedBox(height: 10),
            const Text(
              'Matrimonial',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            buildInfoCard("Meet Our Team", [
              {"label": "Developed by", "value": "Vardhan Ghelani (23010101088)"},
              {"label": "Mentored by", "value": "Prof. Mehul Bhundiya (Computer Engineering Department)"},
              {"label": "Explored by", "value": "ASWDC, School Of Computer Science"},
              {"label": "Eulogized by", "value": "Darshan University, Rajkot, Gujarat - INDIA"},
            ]),

            buildInfoCard("About ASWDC", [
              {"label": "", "value": "ASWDC is Application, Software and Website Development Center at Darshan University."},
              {"label": "", "value": "It bridges the gap between university curriculum & industry demands."},
            ]),
          ],
        ),
      ),
    );
  }
}
