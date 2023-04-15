// abnormal_items_page.dart
import 'package:flutter/material.dart';
import 'database.dart';

class AbnormalItemsPage extends StatefulWidget {
  @override
  _AbnormalItemsPageState createState() => _AbnormalItemsPageState();
}

class _AbnormalItemsPageState extends State<AbnormalItemsPage> {
  late Future<List<AbnormalItem>> _abnormalItems;

  @override
  void initState() {
    super.initState();
    _abnormalItems = getAbnormalItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _abnormalItems = getAbnormalItems();
    });
  }

  List<Widget> buildAbnormalItemList(List<AbnormalItem> abnormalItems) {
    return abnormalItems.asMap().entries.map((entry) {
      int index = entry.key;
      AbnormalItem item = entry.value;
      return Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            color: index % 2 == 0 ? Colors.grey[300] : Colors.grey[200],
          ),
          child: ListTile(
            title: Text(
              '관리번호: ${item.managementNumber}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '전산재고위치: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  TextSpan(
                    text: '${item.dbLocation} / ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  TextSpan(
                    text: '실재재고위치: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(
                    text: '${item.actualLocation}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
            onTap: () async {
              bool isConfirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('실재재고 위치를 수정하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('수정'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (isConfirmed) {
                final updatedItem = await getAbnormalItem(item.abnormalKey);
                if (updatedItem != null &&
                    updatedItem.dbLocation == updatedItem.actualLocation) {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('수정이 완료되었습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('화물을 ${item.dbLocation} 위치로 옮겨주세요.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이상 감지'),
      ),
      body: FutureBuilder<List<AbnormalItem>>(
        future: _abnormalItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final abnormalItems = snapshot.data!;
            final itemList = buildAbnormalItemList(abnormalItems);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: itemList,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
