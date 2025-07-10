import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/address_model.dart';
import '../models/challenge_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Interface Definition ---

abstract class ChallengeRemoteDataSource {
  Stream<List<ChallengeModel>> getAllChallengesStream();
  Future<ChallengeModel?> getChallengeById(String challengeId);
  Future<String> createChallenge(ChallengeModel challenge);
  Future<String?> fetchLlmFeedback({
    required String step,
    required Map<String, dynamic> challengeJson,
  });
  Future<List<AddressModel>> searchLocation(String query);
}


// --- Implementierung ---

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  final FirebaseFirestore firestore;

  List<Map<String, dynamic>>? _sdgContextCache;

  ChallengeRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ChallengeModel>> getAllChallengesStream() {
    try {
      AppLogger.info("ChallengeRemoteDS: Starting getAllChallengesStream");
      return firestore.collection('/challenges')
          .snapshots()
          .map(_processSnapshot)
          .handleError((error) {
        AppLogger.warning("ChallengeRemoteDS: Fallback-Query wird versucht: $error");
        return firestore.collection('challenges').snapshots().map(_processSnapshot);
      });
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Exception in getAllChallengesStream: $e", e);
      return Stream.value([]);
    }
  }

  List<ChallengeModel> _processSnapshot(QuerySnapshot snapshot) {
    AppLogger.info("ChallengeRemoteDS: Snapshot mit ${snapshot.docs.length} Dokumenten empfangen.");
    final challenges = <ChallengeModel>[];
    for (var doc in snapshot.docs) {
      try {
        final challenge = ChallengeModel.fromSnapshot(doc);
        challenges.add(challenge);
      } catch (e) {
        AppLogger.error("ChallengeRemoteDS: Fehler beim Verarbeiten von Dokument ${doc.id}: $e", e);
      }
    }
    return challenges;
  }

  @override
  Future<ChallengeModel?> getChallengeById(String challengeId) async {
    try {
      final doc = await firestore.collection('challenges').doc(challengeId).get();
      if (doc.exists) {
        return ChallengeModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Fehler bei getChallengeById $challengeId: $e", e);
      throw Exception('Failed to get challenge by ID: $e');
    }
  }

  @override
  Future<String> createChallenge(ChallengeModel challenge) async {
    try {
      final docRef = await firestore.collection('challenges').add(challenge.toMap());
      return docRef.id;
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Fehler bei createChallenge: $e", e);
      throw Exception('Failed to create challenge: $e');
    }
  }

  @override
  Future<List<AddressModel>> searchLocation(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=jsonv2&limit=5');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.flutter_sdg'});
      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List;
        return results.map((data) => AddressModel.fromMap(data as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error("Nominatim search error", e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getSdgContext() async {
    _sdgContextCache ??= await rootBundle.loadString('assets/data/all_sdg_data.json').then((jsonStr) {
      final List<dynamic> allSdgs = json.decode(jsonStr);
      return allSdgs.map((sdg) => {
        'id': sdg['id'],
        'title': sdg['title'],
        'description': (sdg['descriptionPoints'] as List).first,
      }).toList();
    });
    return _sdgContextCache!;
  }

  @override
  Future<String?> fetchLlmFeedback({
    required String step,
    required Map<String, dynamic> challengeJson,
  }) async {
    try {
      final responseSchema = Schema.object(
        properties: {
          'quality_score': Schema.integer(description: "Eine Bewertung des Inputs auf einer Skala von 1 (schlecht) bis 5 (exzellent)."),
          'feedback_tone': Schema.enumString(description: "Die Tonalität des Feedbacks.", enumValues: ['POSITIVE', 'NEUTRAL', 'CONSTRUCTIVE']),
          'main_feedback': Schema.string(description: "Der Feedback-Satz (maximal 2 Sätze), der in der App angezeigt wird."),
          'improvement_suggestion': Schema.string(description: "Ein konkreter Verbesserungsvorschlag oder ein leerer String, wenn keiner nötig ist."),
        },
      );

      // 2. Initialisiere das Gemini-Modell mit der JSON-Konfiguration.
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
        ),
      );

      // 3. Baue den dynamischen und detaillierten Prompt auf.
      final promptContext = {
        "target_language": challengeJson['language'] ?? 'en',
        "current_step": step,
        "challenge_data": {
          "title": challengeJson['title'],
          "description": challengeJson['description'],
          "selected_categories": challengeJson['categories'] ?? [],
        }
      };

      if (step == 'description' || step == 'categories') {
        promptContext['sdg_definitions'] = await _getSdgContext();
      }

      final structuredPrompt = {
        "system_instructions": {
          "persona": "You are 'Sphera', a friendly, motivating, and slightly playful coach for a sustainability app. Your primary language for instructions is English, but your final output to the user (the JSON values) MUST be in the 'target_language' specified in the context.",
          "task": "Your task is to evaluate user-submitted data for a new challenge they are creating. You must provide structured feedback by generating a JSON object that strictly adheres to the provided schema. Be positive and encouraging, even when providing constructive criticism."
        },
        "context": promptContext,
        "examples": [
          {
            "input": { "challenge_data": { "title": "Plogging" } },
            "output": {
              "quality_score": 3,
              "feedback_tone": "NEUTRAL",
              "main_feedback": "Ein guter Anfang! 'Plogging' ist ein bekannter Begriff, aber vielleicht nicht für jeden verständlich.",
              "improvement_suggestion": "Wie wäre es mit 'Plogging-Runde im Park'? Das ist einladender und klarer."
            }
          },
          {
            "input": { "challenge_data": { "title": "Rette die Bienen: Baue ein Insektenhotel" } },
            "output": {
              "quality_score": 5,
              "feedback_tone": "POSITIVE",
              "main_feedback": "Wow, das ist ein fantastischer Titel! Er ist kreativ, klar und zeigt sofort den positiven Einfluss.",
              "improvement_suggestion": ""
            }
          }
        ],
        "task_instructions": {
          "request": "Analyze the 'challenge_data' within the given 'context'. If 'sdg_definitions' are provided, use them to verify that the challenge description and selected categories are a good thematic fit. Generate a JSON response that strictly follows the schema. All string values in your JSON output ('main_feedback', 'improvement_suggestion') MUST be written in the language specified by 'target_language'."
        }
      };

      final promptString = json.encode(structuredPrompt);
      final content = [Content.text(promptString)];
      final response = await model.generateContent(content);

      return response.text;

    } catch (e) {
      AppLogger.error("LLM DataSource Error", e);
      return null;
    }
  }

}