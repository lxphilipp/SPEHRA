import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAppCheck appCheck;

  List<Map<String, dynamic>>? _sdgContextCache;

  ChallengeRemoteDataSourceImpl({required this.firestore, required this.appCheck});

  @override
  Stream<List<ChallengeModel>> getAllChallengesStream() {
    try {
      AppLogger.info("ChallengeRemoteDS: Starting getAllChallengesStream");
      return firestore.collection('/challenges')
          .snapshots()
          .map(_processSnapshot)
          .handleError((error) {
        AppLogger.warning("ChallengeRemoteDS: Fallback query is being attempted: $error");
        return firestore.collection('challenges').snapshots().map(_processSnapshot);
      });
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Exception in getAllChallengesStream: $e", e);
      return Stream.value([]);
    }
  }

  List<ChallengeModel> _processSnapshot(QuerySnapshot snapshot) {
    AppLogger.info("ChallengeRemoteDS: Snapshot with ${snapshot.docs.length} documents received.");
    final challenges = <ChallengeModel>[];
    for (var doc in snapshot.docs) {
      try {
        final challenge = ChallengeModel.fromSnapshot(doc);
        challenges.add(challenge);
      } catch (e) {
        AppLogger.error("ChallengeRemoteDS: Error processing document ${doc.id}: $e", e);
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
      AppLogger.error("ChallengeRemoteDS: Error at getChallengeById $challengeId: $e", e);
      throw Exception('Failed to get challenge by ID: $e');
    }
  }

  @override
  Future<String> createChallenge(ChallengeModel challenge) async {
    try {
      final docRef = await firestore.collection('challenges').add(challenge.toMap());
      return docRef.id;
    } catch (e) {
      AppLogger.error("ChallengeRemoteDS: Error at createChallenge: $e", e);
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
          'quality_score': Schema.integer(description: "A rating of the input on a scale from 1 (poor) to 5 (excellent)."),
          'feedback_tone': Schema.enumString(description: "The tonality of the feedback.", enumValues: ['POSITIVE', 'NEUTRAL', 'CONSTRUCTIVE']),
          'main_feedback': Schema.string(description: "The main feedback sentence (max 2 sentences) to be displayed in the app."),
          'improvement_suggestion': Schema.string(description: "A concrete suggestion for improvement, or an empty string if none is needed."),
        },
      );

      final model = FirebaseAI.googleAI(appCheck: appCheck).generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: responseSchema,
        ),
      );

      final promptContext = {
        "target_language": challengeJson['language'] ?? 'en',
        "current_step": step,
        "challenge_data": {
          "title": challengeJson['title'],
          "description": challengeJson['description'],
          "selected_categories": challengeJson['categories'] ?? [],
          "tasks": challengeJson['tasks'] ?? [],
        }
      };

      if (step == 'description' || step == 'categories' || step == 'tasks') {
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
            "input": {
              "challenge_data": {
                "title": "Save the Bees: Build an Insect Hotel",
                "description": "We are building a home for wild bees and other insects to promote local biodiversity.",
                "selected_categories": ["goal1", "goal2"]
              }
            },
            "output": {
              "quality_score": 2,
              "feedback_tone": "CONSTRUCTIVE",
              "main_feedback": "The categories 'No Poverty' and 'Zero Hunger' don't quite fit the theme of bees and biodiversity.",
              "improvement_suggestion": "Try 'Life on Land' (SDG 15). That would be a perfect match!"
            }
          },
          {
            "input": { "challenge_data": { "title": "Plogging" } },
            "output": {
              "quality_score": 3,
              "feedback_tone": "NEUTRAL",
              "main_feedback": "A good start! 'Plogging' is a known term, but maybe not understandable for everyone.",
              "improvement_suggestion": "How about 'Plogging round in the park'? That's more inviting and clear."
            }
          },
          {
            "input": { "challenge_data": { "title": "Save the Bees: Build an Insect Hotel" } },
            "output": {
              "quality_score": 5,
              "feedback_tone": "POSITIVE",
              "main_feedback": "Wow, that's a fantastic title! It's creative, clear, and immediately shows the positive impact.",
              "improvement_suggestion": ""
            }
          }
        ],
        "task_instructions": {
          "request": "Analyze the 'challenge_data' within the given 'context'. If 'sdg_definitions' are provided, use them to verify that the challenge description and selected categories are a good thematic fit. For the 'tasks' step, evaluate if the tasks are balanced and meaningful. Generate a JSON response that strictly follows the schema. All string values in your JSON output ('main_feedback', 'improvement_suggestion') MUST be written in the language specified by 'target_language'."
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