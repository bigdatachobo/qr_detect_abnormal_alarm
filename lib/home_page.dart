import 'package:flutter/material.dart';
import 'abnormal_list_page.dart';
import 'database.dart';
import 'qr_scanner_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void initState() {
    super.initState();
    startMonitoringAbnormalItemCount();
  }

  @override
  void dispose() {
    stopMonitoringAbnormalItemCount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.8 / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerPage(
                            isInbound: true,
                            isMoving: false,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.lightBlue,
                      child: Text(
                        '입고',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerPage(
                            isInbound: false,
                            isMoving: false,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.lightGreen,
                      child: Text(
                        '출고',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerPage(
                            isInbound: false,
                            isMoving: true,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.yellowAccent[100],
                      child: Text(
                        '이동',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AbnormalItemsPage(),
                        ),
                      );
                    },
                    child: StreamBuilder<int>(
                      stream: abnormalItemCountController.stream,
                      builder: (context, snapshot) {
                        int count = snapshot.data ?? 0;
                        bool isAlert = count > 0;
                        return Container(
                          alignment: Alignment.center,
                          color: isAlert ? Colors.redAccent[200] : Colors.grey,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Text(
                                    '위치\n오류',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // textAlign: TextAlign.center,
                                  ),
                              ),
                              // if (isAlert)
                                Positioned(
                                  top: 0,
                                  right: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 30,
                                      minHeight: 30,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}