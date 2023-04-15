import 'dart:async';
import 'dart:typed_data';

import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String host = dotenv.env['AWS_HOST']!;
final int port = int.parse(dotenv.env['AWS_PORT']!);
final String? user = dotenv.env['AWS_USER'];
final String? password = dotenv.env['AWS_PASSWORD'];
final String? db = dotenv.env['AWS_DB_NAME'];

Future<MySqlConnection> _getConnection() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: host,
    port: port,
    user: user,
    password: password,
    db: db,
  ));
  return conn;
}

// UW1_재고 조회
Future<void> addOrUpdateItem(String code, String locationKey) async {
  final conn = await _getConnection();
  try {
    await conn.query(
      // 'UPDATE `VMStset`.`UW1_재고` SET `관리번호` = ? WHERE `LocationKey` = ?',
      'UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = ? WHERE `LocationKey` = ?',
      [code, locationKey],
    );
  } finally {
    await conn.close();
  }
}

Future<void> setItemAsOutbound(String code) async {
  final conn = await _getConnection();
  try {
    await conn.query(
      // "UPDATE `VMStset`.`UW1_재고` SET `관리번호` = '' WHERE `관리번호` = ?",
      "UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = '' WHERE `관리번호` = ?",
      [code],
    );
  } finally {
    await conn.close();
  }
}

Future<List<String>> getEmptySpaces() async {
  final conn = await _getConnection();
  List<String> emptySpaces = [];

  try {
    final results = await conn.query(
      // "SELECT `LocationKey` FROM `VMStset`.`UW1_재고` WHERE `관리번호` = ''",
      "SELECT `LocationKey` FROM `VMStset`.`UW1_재고_Eng` WHERE `관리번호` = ''",
    );

    for (var row in results) {
      emptySpaces.add(row[0].toString());
    }
  } finally {
    await conn.close();
  }

  return emptySpaces;
}

Future<void> moveItem(String code, String newLocationKey) async {
  final conn = await _getConnection();
  try {
    // Set the 관리번호 to an empty string in the old location
    await conn.query(
      // "UPDATE `VMStset`.`UW1_재고` SET `관리번호` = '' WHERE `관리번호` = ?",
      "UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = '' WHERE `관리번호` = ?",
      [code],
    );

    // Update the 관리번호 in the new location
    await conn.query(
      // 'UPDATE `VMStset`.`UW1_재고` SET `관리번호` = ? WHERE `LocationKey` = ?',
      'UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = ? WHERE `LocationKey` = ?',
      [code, newLocationKey],
    );
  } finally {
    await conn.close();
  }
}

// Abnormal Table
class AbnormalItem {
  String abnormalKey;
  String managementNumber;
  String dbLocation;
  String actualLocation;

  AbnormalItem({
    required this.abnormalKey,
    required this.managementNumber,
    required this.dbLocation,
    required this.actualLocation,
  });
}

Future<List<AbnormalItem>> getAbnormalItems() async {
  // 여기에 데이터베이스 연결 및 쿼리 로직을 작성해야 합니다.
  // 예시:
  final conn = await _getConnection();
  final results = await conn.query(
      'SELECT `abnormalKey`, `관리번호`, `전산재고위치`, `실재재고위치` FROM `Abnormal_Detection` WHERE `전산재고위치` != `실재재고위치`;');

  // // 결과 출력
  // for (var row in results) {
  //   print('abnormalKey: ${row['abnormalKey']}, type: ${row['abnormalKey'].runtimeType}');
  //   print('관리번호: ${row['관리번호']}, type: ${row['관리번호'].runtimeType}');
  //   print('전산재고위치: ${row['전산재고위치']}, type: ${row['전산재고위치'].runtimeType}');
  //   print('실재재고위치: ${row['실재재고위치']}, type: ${row['실재재고위치'].runtimeType}');
  // }
  return results.map((row) {
    return AbnormalItem(
      abnormalKey: row['abnormalKey'] as String,
      managementNumber: row['관리번호'] as String,
      dbLocation: row['전산재고위치'] as String,
      actualLocation: row['실재재고위치'] as String,
    );
  }).toList();
}

Future<AbnormalItem?> getAbnormalItem(String AbnormalKey) async {
  final conn = await _getConnection();
  final results = await conn.query(
      'SELECT `abnormalKey`, `관리번호`, `전산재고위치`, `실재재고위치` FROM `Abnormal_Detection` WHERE `관리번호` = ?;',
      [AbnormalKey]);

  if (results.isNotEmpty) {
    final row = results.first;
    return AbnormalItem(
      abnormalKey: row['abnormalKey'] as String,
      managementNumber: row['관리번호'] as String,
      dbLocation: row['전산재고위치'] as String,
      actualLocation: row['실재재고위치'] as String,
    );

  }

  return null;
}

StreamController<int> abnormalItemCountController = StreamController<int>.broadcast();

Future<void> startMonitoringAbnormalItemCount() async {
  Timer.periodic(Duration(seconds: 2), (timer) async {
    final conn = await _getConnection();
    final results = await conn.query(
        'SELECT COUNT(*) FROM `Abnormal_Detection` WHERE `전산재고위치` != `실재재고위치`;');
    final count = results.first.values?.first as int;
    abnormalItemCountController.add(count);
  });
}

void stopMonitoringAbnormalItemCount() {
  abnormalItemCountController.close();
}