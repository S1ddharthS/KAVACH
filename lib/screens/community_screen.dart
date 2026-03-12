import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.安安全_rounded, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('No reports yet. Stay safe!', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final description = report['description'] ?? 'No description';
              final imageUrl = report['imageUrl'];
              final timestamp = report['createdAt'] as Timestamp?;
              final location = report['location'] as GeoPoint?;

              String formattedDate = 'Just now';
              if (timestamp != null) {
                formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Chip(
                                label: Text('CRIME REPORT', style: TextStyle(color: Colors.white, fontSize: 10)),
                                backgroundColor: Colors.redAccent,
                              ),
                              Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          if (location != null)
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  'Loc: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(color: Colors.blue[800], fontSize: 14),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
