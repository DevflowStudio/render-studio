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
    page.multiselect = false;
    page.select(page.backround);
    date -= 1;
    restore(date);
    page.rebuildListeners();
    page.updateListeners(PageChange.update);
  }

  void _redo() {
    page.multiselect = false;
    page.select(page.backround);
    date += 1;
    restore(date);
    page.rebuildListeners();
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
    List<CreatorWidget> _widgets = [];
    for (Map<String, dynamic> _data in data) try {
      CreatorWidget widget = CreatorWidget.fromJSON(_data, page: page, buildInfo: generateBuildInfo());
      _widgets.add(widget);
    } on WidgetCreationException catch (e, stacktrace) {
      analytics.logError(e, cause: 'could not restore history', stacktrace: stacktrace);
      page.project.issues.add(Exception('${_data['name']} failed to rebuild'));
    }
    page.widgets = _widgets;
    page.backround = _widgets.where((element) => element.id == 'background').first as BackgroundWidget;
    page.gridState.reset();
    page.widgets.forEach((widget) {
      widget.updateGrids();
      widget.updateListeners(WidgetChange.misc);
      // widget.stateCtrl.renewKey();
    });
    page.multiselect = false;
    page.select(page.backround);
    page.updateListeners(PageChange.update);
  }

  static List<Map<String, dynamic>> _getJSON(CreatorPage page) {
    List<Map<String, dynamic>> jsons = [];
    for (CreatorWidget widget in page.widgets) {
      jsons.add(widget.toJSON(
        buildInfo: BuildInfo(buildType: BuildType.history)
      ));
    }
    return jsons;
  }

}