import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/winter_arc_model.dart';
import '../models/goal_model.dart';
import '../models/daily_entry_model.dart';

class SyncService {
  static bool _initialized = false;
  static String? _userId;

  static Future<void> initSilently() async {
    try {
      // Check if Firebase apps are available/initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        final credential = await auth.signInAnonymously();
        _userId = credential.user?.uid;
      } else {
        _userId = auth.currentUser?.uid;
      }
      _initialized = true;
      if (kDebugMode) {
        print('Firebase silent sync ready for UID: $_userId');
      }
    } catch (e) {
      // Best-effort offline first: never crash if Firebase is unconfigured or offline
      _initialized = false;
      if (kDebugMode) {
        print('Silent Firebase sync skipped (running fully offline mode): $e');
      }
    }
  }

  static Future<void> syncArc(WinterArc arc) async {
    if (!_initialized || _userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set({'arc': arc.toMap(), 'lastSync': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Background syncArc error: $e');
    }
  }

  static Future<void> syncGoals(List<Goal> goals) async {
    if (!_initialized || _userId == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('goals');

      for (final goal in goals) {
        batch.set(collection.doc(goal.id), goal.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('Background syncGoals error: $e');
    }
  }

  static Future<void> syncDailyEntry(DailyEntry entry) async {
    if (!_initialized || _userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('entries')
          .doc(entry.compositeKey)
          .set(entry.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Background syncDailyEntry error: $e');
    }
  }
}
