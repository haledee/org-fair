import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Sanity (hosted headless CMS), HTTP Query API with GROQ.
///
/// Schema type in your Studio: name 'fairEvent', fields title (string),
/// orgId (string), startsAt (datetime), venue (string),
/// description (text), cancelled (boolean).
///
/// Sanity answers:
/// { "query": "*[_type == ...]",
///   "result": [ { "_id": "4f1c...", "title": "Hour of Code", "orgId": "csc",
///                 "startsAt": "2026-11-08T05:00:00.000Z",
///                 "venue": "CICT Lab 2", "description": null,
///                 "cancelled": null } ],
///   "ms": 4 }
/// The projection {...} asks for exactly these fields; a field that was
/// never filled in comes back as null.
class SanityEventSource implements EventSource {
  SanityEventSource(
    this.client, {
    required this.projectId,
    this.dataset = 'production',
    this.token = '',
  });

  final http.Client client;
  final String projectId;
  final String dataset;

  /// Empty when the dataset is public.
  final String token;

  /// The query, in GROQ: all fairEvent documents, oldest first,
  /// with only the fields the app needs.
  static const query =
      '*[_type == "fairEvent"] | order(startsAt asc) '
      '{_id, title, orgId, startsAt, venue, description, cancelled}';

  @override
  String get name => 'Sanity';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.https(
      '$projectId.apicdn.sanity.io',
      '/v2025-02-19/data/query/$dataset',
      {'query': query},
    );
    
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final json = await getJson(client, uri, cms: name, headers: headers);

    final results = (json as Map<String, dynamic>?)?['result'] as List<dynamic>? ?? [];

    return results.map((item) {
      final map = item as Map<String, dynamic>;
      return FairEvent(
        id: map['_id'] as String,
        title: map['title'] as String,
        orgId: map['orgId'] as String,
        startsAt: DateTime.parse(map['startsAt'] as String),
        venue: map['venue'] as String,
        description: map['description'] ?? '',
        cancelled: map['cancelled'] ?? false,
      );
    }).toList();
  }
}