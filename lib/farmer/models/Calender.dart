import 'package:cloud_firestore/cloud_firestore.dart';

class Calender {
  final int harvestTime;
  final List timestamps;
  final List titles;
  final List subtitles;
  final List links;
  final List imageUrls;

  const Calender({
    required this.timestamps,
    required this.titles,
    required this.subtitles,
    required this.links,
    required this.imageUrls,
    required this.harvestTime,
  });

  factory Calender.fromFirestore(DocumentSnapshot snapshot) {
    // Cast snapshot.data() to a Map<String, dynamic>
    final doc = snapshot.data() as Map<String, dynamic>?;
    print(doc);

    if (doc == null) {
      print("data is null");
      // Handle the case where doc is null
      return Calender(
        timestamps: [],
        titles: [],
        subtitles: [],
        links: [],
        imageUrls: [],
        harvestTime: 0,
      );
    }

    // print(doc["timestamps"]);

    return Calender(
        timestamps: doc["Timestamps"] ??
            doc["TimeStamps"] ??
            doc["TimeStamp"] ??
            doc["Timestamp"] ??
            doc["timestamp"] ??
            doc["timestamps"] ??
            [],
        titles: doc["Title"] ?? doc["title"] ?? doc["titles"] ?? [],
        subtitles: doc["Sub Title"] ?? doc["subtitles"] ?? [],
        links: doc["Links"] ?? doc["link"] ?? doc["links"] ?? [],
        imageUrls: doc["imageUrls"] ?? doc["imageUrl"] ?? [],
        harvestTime: doc["HarvesTime"] ??
            doc["HarvestTime"] ??
            doc["harvestime"] ??
            doc["harvesTime"] ??
            doc["HarvestingTime"] ??
            0
        // timestamps: doc["Timestamps"] ?? [],
        // titles: doc['Titles'] ?? [],
        // subtitles: doc['Subtitles'] ?? [],
        // links: doc['Links'] ?? [],
        // imageUrls: doc['ImageUrls'] ?? [],
        // harvestTime: doc['HarvestTime'] ?? 0,
        );
  }
}
