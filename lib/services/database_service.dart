import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message_model.dart';

class DatabaseService {
  static const String _dbName = 'chat_database.db';
  static const String _tableName = 'messages';
  static const int _dbVersion = 1;

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId TEXT NOT NULL,
        receiverId TEXT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        messageId INTEGER
      )
    ''');
  }

  Future<int> insertMessage(Message message) async {
    final db = await instance.database;
    return await db.insert(_tableName, message.toJson());
  }

  Future<List<Message>> getAllMessages() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return Message.fromJson(maps[i]);
    });
  }

  Future<List<Message>> getMessagesForUser(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'senderId = ? OR receiverId = ?',
      whereArgs: [userId, userId],
    );
    return List.generate(maps.length, (i) {
      return Message.fromJson(maps[i]);
    });
  }

  Future<int> updateMessageStatus(int messageId, String status) async {
    final db = await instance.database;
    return await db.update(
      _tableName,
      {'status': status},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  Future<int> markMessagesAsRead(String senderId) async {
    final db = await instance.database;
    return await db.update(
      _tableName,
      {'isRead': 1},
      where: 'senderId = ? AND isRead = 0',
      whereArgs: [senderId],
    );
  }

  Future<void> clearAllMessages() async {
    final db = await instance.database;
    await db.delete(_tableName);
  }
}
