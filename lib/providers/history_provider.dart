import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_history.dart';

class HistoryProvider with ChangeNotifier {
  static const String _boxName = 'historyBox';
  late Box<AlarmHistory> _box;

  List<AlarmHistory> get historyList {
    if (!_box.isOpen) return [];
    // 최신순 정렬
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  HistoryProvider() {
    _box = Hive.box<AlarmHistory>(_boxName);
  }

  Future<void> addHistory(AlarmHistory history) async {
    await _box.add(history);
    notifyListeners();
  }

  Future<void> deleteHistory(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
  }
  
  // 전체 삭제 (옵션)
  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }
}
