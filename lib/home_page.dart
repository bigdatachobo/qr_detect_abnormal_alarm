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
    final fontSize = screenWidth * 0.34 / 3;

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
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border.all(
                          color: Colors.white,
                          width: 0.05
                        )
                      ),
                      child: Text(
                        '입고',
                          style: TextStyle(
                          color: Colors.white,
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
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          border: Border.all(
                              color: Colors.white,
                              width: 0.05
                          )
                      ),
                      child: Text(
                        '출고',
                        style: TextStyle(
                          color: Colors.white,
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
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          border: Border.all(
                              color: Colors.white,
                              width: 0.05
                          )
                      ),
                      child: Text(
                        '이동',
                        style: TextStyle(
                          color: Colors.white,
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
                          color: isAlert ? Colors.redAccent[200] : Colors.black87,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30 ),
                                child: Text(
                                    '재고\n오류',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // textAlign: TextAlign.center,
                                  ),
                              ),
                              // if (isAlert)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 30,
                                      minHeight: 30,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 20,
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