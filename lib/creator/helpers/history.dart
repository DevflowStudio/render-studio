import '../../rehmat.dart';

class History {

  late List<HistoryDate> dates;
  late CreatorPage page;

  int date = 0;

  String? nextVersion;

  static History create(CreatorPage page, {
    Map? data
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

  String get undoTooltip => undoEnabled ? 'Undo${dates[date].title != null ? ': ' + dates[date].title!.toTitleCase() : ''}' : 'Nothing to Undo';
  String get redoTooltip => redoEnabled ? 'Redo${dates[date + 1].title != null ? ': ' + dates[date + 1].title!.toTitleCase() : ''}' : 'Nothing to Redo';

  void _undo() => restore(-1);

  void _redo() => restore(1);

  /// Logs a new history event with the current state of the page
  /// Uses method [create] to create a new history event
  /// The JSON is fetched from the widgets manager and passed to the [create] method
  /// Pass the `title` to set the title of the history event. May be used as a tooltip in the history menu
  void log([String? title]) {
    HistoryDate event = HistoryDate.create(page, version: nextVersion, title: title);
    nextVersion = Constants.generateID();
    if (dates.length >= 20) dates.removeAt(0);
    if (date < dates.length - 1) dates.removeRange(date + 1, dates.length);
    dates.add(event);
    date = dates.length - 1;
    page.updateListeners(PageChange.misc);
  }

  void restore(int change) {
    // String? selectedWidget = page.widgets.selections.length > 1 ? null : page.widgets.selections.firstOrNull?.uid;
    page.widgets.select();
    date += change;
    dates[date].restore();
    // if (selectedWidget != null) page.widgets.selectWithUID(selectedWidget);
  }

}

class HistoryDate {

  final Map data;
  String? version;
  final String? title;
  final CreatorPage page;

  HistoryDate(this.data, {
    required this.page,
    this.version,
    this.title
  }) {
    version ??= Constants.generateID();
  }

  BuildInfo generateBuildInfo() => BuildInfo(
    version: version,
    buildType: BuildType.history
  );

  static HistoryDate create(CreatorPage page, {
    String? title,
    String? version,
    Map? data,
  }) {
    version ??= Constants.generateID();
    HistoryDate event = HistoryDate(data ?? _getJSON(page, version), page: page, version: version, title: title);
    return event;
  }

  factory HistoryDate.fromData(CreatorPage page, {
    required Map data,
    String? title,
    String? version,
  }) => HistoryDate(data, page: page, version: version, title: title);

  void restore() {
    page.widgets.restoreHistory(List<Map>.from(data['widgets']), version: version);
    page.palette = ColorPalette.fromJSON(data['palette']);
  }

  static Map<String, dynamic> _getJSON(CreatorPage page, String version) => page.toJSON(
    BuildInfo(
      version: version,
      buildType: BuildType.history
    )
  );

}