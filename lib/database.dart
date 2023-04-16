import 'dart:async';

import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String host = dotenv.env['AWS_HOST']!;
final int port = int.parse(dotenv.env['AWS_PORT']!);
final String? user = dotenv.env['AWS_USER'];
final String? password = dotenv.env['AWS_PASSWORD'];
final String? db = dotenv.env['AWS_DB_NAME'];

// MySqlConnectionPool 클래스를 추가합니다.
class MySqlConnectionPool {
  final int poolSize;
  final List<MySqlConnection> _connections = [];

  MySqlConnectionPool({required this.poolSize});

  Future<MySqlConnection> _createConnection() async {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );

    return MySqlConnection.connect(settings);
  }

  Future<MySqlConnection> getConnection() async {
    if (_connections.isEmpty) {
      if (_connections.length < poolSize) {
        return _createConnection();
      } else {
        return Future.delayed(Duration(milliseconds: 100), getConnection);
      }
    } else {
      final conn = _connections.removeLast();
      return conn;
    }
  }

  void releaseConnection(MySqlConnection conn) {
    _connections.add(conn);
  }

  Future<void> close() async {
    for (final conn in _connections) {
      await conn.close();
    }
  }
}

// MySqlConnectionPool 객체를 전역 변수로 생성합니다.
final connectionPool = MySqlConnectionPool(poolSize: 10);

// 나머지 코드는 이전과 동일하며, MySqlConnectionPool에서 연결을 가져오고 반환하는 방식으로 변경되었습니다.

// 기존의 _getConnection() 함수를 제거합니다.

// 함수들에서 커넥션을 가져오고 반환하는 방식으로 변경합니다.
// 예: addOrUpdateItem 함수

// UW1_재고 조회
Future<void> addOrUpdateItem(String code, String locationKey) async {
  final conn = await connectionPool.getConnection(); // 커넥션을 가져옵니다.
  try {
    await conn.query(
      'UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = ? WHERE `LocationKey` = ?',
      [code, locationKey],
    );
  } finally {
    connectionPool.releaseConnection(conn); // 작업이 완료되면 커넥션을 반환합니다.
  }
}

// 나머지 함수들도 동일하게 수정해야 합니다.

// 애플리케이션 종료 시 커넥션 풀을 닫아야 합니다.
// 이 작업은 main.dart 파일에서 애플리케이션 종료 시 호출되는 함수 내에서 처리해


Future<void> setItemAsOutbound(String code) async {
  final conn = await connectionPool.getConnection();
  try {
    await conn.query(
      // "UPDATE `VMStset`.`UW1_재고` SET `관리번호` = '' WHERE `관리번호` = ?",
      "UPDATE `VMStset`.`UW1_재고_Eng` SET `관리번호` = '' WHERE `관리번호` = ?",
      [code],
    );
  } finally {
    connectionPool.releaseConnection(conn);
  }
}

Future<List<String>> getEmptySpaces() async {
  final conn = await connectionPool.getConnection();
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
    connectionPool.releaseConnection(conn);
  }

  return emptySpaces;
}

Future<void> moveItem(String code, String newLocationKey) async {
  final conn = await connectionPool.getConnection();
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
    connectionPool.releaseConnection(conn);
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
  final conn = await connectionPool.getConnection();
  try {
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
  } finally {
    connectionPool.releaseConnection(conn);
  }
}

Future<AbnormalItem?> getAbnormalItem(String AbnormalKey) async {
  final conn = await connectionPool.getConnection();
  try {
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
  } finally{
    connectionPool.releaseConnection(conn);
  }
}

StreamController<int> abnormalItemCountController = StreamController<int>.broadcast();

Future<void> startMonitoringAbnormalItemCount() async {
  Timer.periodic(Duration(seconds: 2), (timer) async {
    MySqlConnection? conn;

    try {
      conn = await connectionPool.getConnection();
      final results = await conn.query(
          'SELECT COUNT(*) FROM `Abnormal_Detection` WHERE `전산재고위치` != `실재재고위치`;');
      final count = results.first.values?.first as int;
      abnormalItemCountController.add(count);
    } finally {
      if (conn != null) {
        connectionPool.releaseConnection(conn); // 커넥션을 반환합니다.
      }
    }
  });
}

void stopMonitoringAbnormalItemCount() {
  abnormalItemCountController.close();
}

Future<void> deleteAbnormalItem(String abnormalKey) async {
  final conn = await connectionPool.getConnection();
  try {
    await conn.query(
      'DELETE FROM `Abnormal_Detection` WHERE `abnormalKey` = ?;',
      [abnormalKey],
    );
  } finally {
    connectionPool.releaseConnection(conn);
  }
}