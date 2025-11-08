import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Mock Firebase Auth for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Mock User Credential for testing
class MockUserCredential extends Mock implements UserCredential {}

/// Mock User for testing
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => 'https://example.com/photo.jpg';

  @override
  bool get emailVerified => true;
}

/// Mock Firestore for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Mock Collection Reference
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

/// Mock Document Reference
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

/// Mock Document Snapshot
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic>? _data;
  final bool _exists;

  MockDocumentSnapshot({
    required String id,
    Map<String, dynamic>? data,
    bool exists = true,
  })  : _id = id,
        _data = data,
        _exists = exists;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _exists;
}

/// Mock Query Snapshot
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;

  MockQuerySnapshot({required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs})
      : _docs = docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;

  @override
  int get size => _docs.length;
}

/// Mock Query Document Snapshot
class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  MockQueryDocumentSnapshot({
    required String id,
    required Map<String, dynamic> data,
  })  : _id = id,
        _data = data;

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;

  @override
  bool get exists => true;
}

/// Mock Firebase Storage
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

/// Mock Storage Reference
class MockReference extends Mock implements Reference {}

/// Mock Upload Task
class MockUploadTask extends Mock implements UploadTask {}

/// Mock Task Snapshot
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

/// Helper to create mock user data
Map<String, dynamic> createMockUserData({
  String? uid,
  String? email,
  String? displayName,
  String? photoURL,
  DateTime? createdAt,
}) {
  return {
    'uid': uid ?? 'test-user-id',
    'email': email ?? 'test@example.com',
    'displayName': displayName ?? 'Test User',
    'photoURL': photoURL ?? 'https://example.com/photo.jpg',
    'createdAt': createdAt ?? DateTime.now(),
  };
}

/// Helper to create mock chat data
Map<String, dynamic> createMockChatData({
  String? id,
  String? userId,
  String? title,
  List<Map<String, dynamic>>? messages,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return {
    'id': id ?? 'test-chat-id',
    'userId': userId ?? 'test-user-id',
    'title': title ?? 'Test Chat',
    'messages': messages ?? [],
    'createdAt': createdAt ?? DateTime.now(),
    'updatedAt': updatedAt ?? DateTime.now(),
  };
}

/// Helper to create mock message data
Map<String, dynamic> createMockMessageData({
  String? id,
  String? content,
  String? role,
  DateTime? timestamp,
}) {
  return {
    'id': id ?? 'test-message-id',
    'content': content ?? 'Test message',
    'role': role ?? 'user',
    'timestamp': timestamp ?? DateTime.now(),
  };
}

/// Helper to create mock model data
Map<String, dynamic> createMockModelData({
  String? id,
  String? name,
  String? provider,
  bool? isAvailable,
}) {
  return {
    'id': id ?? 'test-model-id',
    'name': name ?? 'Test Model',
    'provider': provider ?? 'openai',
    'isAvailable': isAvailable ?? true,
  };
}
