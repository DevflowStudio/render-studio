import '../../rehmat.dart';
import 'package:collection/collection.dart';

class History {

  late List<HistoryDate> dates;
  late CreatorPage page;

  int date = 0;

  String? nextVersion;

  static History build(CreatorPage page, {
    List<Map<String, dynamic>>? data
  }) {
    History history = History();
    history.dates = [HistoryDate.create(page, data: data)];
    history.page = page;
    history.nextVersion = Constants.generateID();
    return history;
  }

  Function()? get undo => undoEnabled ? _undo : null;
  Function()? get redo => redoEnabled ? _redo : null;

  bool get hasHistory => dates.length > 1;

  bool get undoEnabled => date > 0;
  bool get redoEnabled => dates.length > date + 1;

  void _undo() {
    page.widgets.select();
    date -= 1;
    restore(date);
    page.widgets.rebuildListeners();
    page.updateListeners(PageChange.update);
  }

  void _redo() {
    page.widgets.select();
    date += 1;
    restore(date);
    page.widgets.rebuildListeners();
    page.updateListeners(PageChange.update);
  }

  Future<void> log() async {
    HistoryDate event = await HistoryDate.create(page, version: nextVersion);
    nextVersion = Constants.generateID();
    if (dates.length >= 20) dates.removeAt(0);
    if (date < dates.length - 1) dates.removeRange(date + 1, dates.length);
    Function eq =  const DeepCollectionEquality().equals;
    if (!eq(event, dates.last)) {
      dates.add(event);
      date = dates.length - 1;
    }
    page.updateListeners(PageChange.update);
  }

  void restore(int date) => dates[date].restore();

}

class HistoryDate {

  final List<Map<String, dynamic>> data;
  String? version;
  final CreatorPage page;

  HistoryDate(this.data, {
    required this.page,
    this.version
  }) {
    version ??= Constants.generateID();
  }

  BuildInfo generateBuildInfo() => BuildInfo(
    version: version,
    buildType: BuildType.history
  );

  static HistoryDate create(CreatorPage page, {
    String? version,
    List<Map<String, dynamic>>? data
  }) {
    version ??= Constants.generateID();
    HistoryDate event = HistoryDate(data ?? _getJSON(page), page: page, version: version);
    return event;
  }

  void restore() {
    page.widgets.restoreHistory(data);
  }

  static List<Map<String, dynamic>> _getJSON(CreatorPage page) => page.widgets.toJSON();

}