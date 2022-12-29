import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../rehmat.dart';

class CreativePieChart extends CreatorWidget {

  CreativePieChart({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreativePieChart widget = CreativePieChart(page: page);
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    data = [
      _CreativePieChartSection(
        title: 'Section 1',
        value: 25,
        color: page.palette.primary
      ),
      _CreativePieChartSection(
        title: 'Section 2',
        value: 15,
        color: page.palette.secondary
      ),
      _CreativePieChartSection(
        title: 'Section 3',
        value: 10,
        color: page.palette.tertiary
      ),
      _CreativePieChartSection(
        title: 'Section 4',
        value: 30,
        color: page.palette.surface
      ),
    ];
    super.onInitialize();
  }

  // Inherited
  final String name = 'Pie Chart';
  @override
  final String id = 'pie-chart';

  bool keepAspectRatio = false;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(200, 150);
  @override
  Size? minSize = Size(160, 130);

  late List<_CreativePieChartSection> data;

  bool showLegend = true;

  bool showChartValues = true;
  bool showChartValuesOutside = true;
  bool showChartValuesInPercentage = false;
  bool showChartValueBackground = true;

  ChartType chartType = ChartType.disc;

  double initialAngle = 0;

  double legendSpacing = 20;

  double strokeWidth = 20;

  int decimalPlaces = 0;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Data',
          onTap: (context) => Alerts.modal(
            context,
            title: 'Pie Chart Data',
            childBuilder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (_CreativePieChartSection section in data) ListTile(
                  leading: ColorSelector(
                    title: 'Color',
                    size: Size(40, 40),
                    palette: page.palette,
                    allowOpacity: true,
                    onColorSelect: (color) {
                      section.color = color;
                      updateListeners(WidgetChange.update);
                      setState(() {});
                    },
                    color: section.color,
                    tooltip: 'tooltip'
                  ),
                  minLeadingWidth: 1,
                  title: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          initialValue: section.title,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                            )
                          ),
                          onFieldSubmitted: (value) {
                            section.title = value;
                            updateListeners(WidgetChange.update);
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          initialValue: section.value.toString(),
                          decoration: InputDecoration(
                            hintText: 'Value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                            )
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            try {
                              section.value = double.parse(value);
                            } catch (e) {
                              section.value = 0;
                            }
                            updateListeners(WidgetChange.misc);
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                  trailing: OutlinedIconButtons(
                    icon: Icon(RenderIcons.delete),
                    onPressed: () {
                      data.remove(section);
                      updateListeners(WidgetChange.update);
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(RenderIcons.add),
                  title: Text('Add Section'),
                  onTap: () async {
                    data.add(
                      _CreativePieChartSection(
                        title: 'Section ${data.length + 1}',
                        // set the value parameter to the average of all the values in the data list
                        value: data.length > 0 ? data.map((e) => e.value).reduce((value, element) => value + element) / data.length : 0,
                        color: page.palette.colors.getRandom()
                      )
                    );
                    updateListeners(WidgetChange.update);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          icon: RenderIcons.edit
        ),
        Option.button(
          title: 'Customize',
          onTap: (context) => Alerts.modal(
            context,
            title: 'Customize Pie Chart',
            childBuilder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Chart Type'),
                  trailing: GestureDetector(
                    onTap: () => Alerts.picker(
                      context,
                      itemExtent: 2,
                      children: [
                        Text('Disc'),
                        Text('Ring'),
                      ],
                      initialIndex: chartType == ChartType.disc ? 0 : 1,
                      onSelectedItemChanged: (value) {
                        chartType = value == 0 ? ChartType.disc : ChartType.ring;
                        updateListeners(WidgetChange.misc);
                        setState(() { });
                      },
                    ),
                    child: Chip(
                      label: Text(chartType == ChartType.disc ? 'Disc' : 'Ring'),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Show Legends'),
                  trailing: Switch.adaptive(
                    value: showLegend,
                    onChanged: (value) {
                      showLegend = value;
                      updateListeners(WidgetChange.update);
                      setState(() { });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Show Labels'),
                  trailing: Switch.adaptive(
                    value: showChartValues,
                    onChanged: (value) {
                      showChartValues = value;
                      updateListeners(WidgetChange.update);
                      setState(() { });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Labels Position'),
                  trailing: GestureDetector(
                    onTap: showChartValues ? () => Alerts.picker(
                      context,
                      itemExtent: 2,
                      children: [
                        Text('Inside'),
                        Text('Outside'),
                      ],
                      initialIndex: showChartValuesOutside ? 1 : 0,
                      onSelectedItemChanged: (value) {
                        showChartValuesOutside = value == 1;
                        updateListeners(WidgetChange.update);
                        setState(() { });
                      },
                    ) : null,
                    child: Chip(
                      label: Text(showChartValuesOutside ? 'Outside' : 'Inside'),
                    ),
                  )
                ),
                ListTile(
                  title: Text('Add Background to Labels'),
                  trailing: Switch.adaptive(
                    value: showChartValueBackground,
                    onChanged: showChartValues ? (value) {
                      showChartValueBackground = value;
                      updateListeners(WidgetChange.update);
                      setState(() { });
                    } : null,
                  ),
                ),
                ListTile(
                  title: Text('Show Labels in Percentage'),
                  trailing: Switch.adaptive(
                    value: showChartValuesInPercentage,
                    onChanged: showChartValues ? (value) {
                      showChartValuesInPercentage = value;
                      updateListeners(WidgetChange.update);
                      setState(() { });
                    } : null,
                  ),
                )
              ],
            ),
          ),
          icon: RenderIcons.pieChart
        ),
        if (chartType == ChartType.ring) Option.showSlider(
          title: 'Stroke Width',
          icon: RenderIcons.align_bottom,
          value: strokeWidth,
          min: 5,
          max: 30,
          onChange: (value) {
            strokeWidth = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            strokeWidth = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          title: 'Angle',
          icon: RenderIcons.rotate,
          value: initialAngle,
          min: -180,
          max: 180,
          snapPoints: [
            -135,
            -90,
            -45,
            0,
            45,
            90,
            135,
          ],
          onChange: (value) {
            initialAngle = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            initialAngle = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          title: 'Legend Spacing',
          icon: RenderIcons.word_spacing,
          value: legendSpacing,
          min: 0,
          max: 50,
          snapPoints: [
            20,
            30
          ],
          onChange: (value) {
            legendSpacing = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            legendSpacing = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Decimal Places',
          onTap: (context) => EditorTab.modal(
            context,
            tab: EditorTab.picker(
              title: 'Decimal Places',
              children: [
                Text('0'),
                Text('1'),
                Text('2'),
              ],
              initialIndex: decimalPlaces,
              onSelectedItemChanged: (value) {
                decimalPlaces = value;
                updateListeners(WidgetChange.update);
              },
            )
          ),
          icon: decimalPlaces == 0 ? RenderIcons.number_zero : decimalPlaces == 1 ? RenderIcons.number_one : RenderIcons.number_two,
        ),
        ... defaultOptions,
      ],
      tab: 'Pie Chart',
    ),
    EditorTab.adjustTab(
      widget: this,
      rotate: false,
    )
  ];

  @override
  Widget widget(BuildContext context) => Center(
    child: PieChart(
      dataMap: {
        for (_CreativePieChartSection section in data) section.title: section.value
      },
      chartRadius: size.width / 2 - (chartType == ChartType.disc ? 0 : strokeWidth / 2),
      legendOptions: LegendOptions(
        showLegends: showLegend,
        legendTextStyle: TextStyle(
          color: page.palette.onBackground,
          fontWeight: FontWeight.w500
        )
      ),
      colorList: [
        for (_CreativePieChartSection section in data) section.color
      ],
      chartValuesOptions: ChartValuesOptions(
        showChartValues: showChartValues,
        decimalPlaces: decimalPlaces,
        showChartValuesOutside: showChartValuesOutside,
        showChartValuesInPercentage: showChartValuesInPercentage,
        showChartValueBackground: showChartValueBackground,
        chartValueBackgroundColor: page.palette.onBackground
      ),
      chartType: chartType,
      degreeOptions: DegreeOptions(
        initialAngle: initialAngle
      ),
      legendLabels: {
        for (_CreativePieChartSection section in data) section.title: section.title
      },
      chartLegendSpacing: legendSpacing,
      ringStrokeWidth: strokeWidth,
      animationDuration: Duration.zero,
    ),
  );

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'data': data.map((e) => e.toJSON()).toList(),
    'show-legend': showLegend,
    'show-chart-values': showChartValues,
    'show-chart-values-outside': showChartValuesOutside,
    'show-chart-value-background': showChartValueBackground,
    'show-chart-values-in-percentage': showChartValuesInPercentage,
    'decimal-places': decimalPlaces,
    'chart-type': chartType.index,
    'stroke-width': strokeWidth,
    'initial-angle': initialAngle,
    'legend-spacing': legendSpacing,
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      data = [];
      for (var section in json['data']) {
        data.add(_CreativePieChartSection.fromJSON(Map.from(section)));
      }
      showLegend = json['show-legend'];
      showChartValues = json['show-chart-values'];
      showChartValuesOutside = json['show-chart-values-outside'];
      showChartValueBackground = json['show-chart-value-background'];
      showChartValuesInPercentage = json['show-chart-values-in-percentage'];
      decimalPlaces = json['decimal-places'];
      chartType = ChartType.values[json['chart-type']];
      strokeWidth = json['stroke-width'];
      initialAngle = json['initial-angle'];
      legendSpacing = json['legend-spacing'];
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}

class _CreativePieChartSection {

  String title;
  double value;
  Color color;

  _CreativePieChartSection({
    required this.title,
    required this.value,
    required this.color,
  });

  Map<String, dynamic> toJSON() => {
    'title': title,
    'value': value,
    'color': color.toHex(),
  };

  factory _CreativePieChartSection.fromJSON(Map<String, dynamic> json) => _CreativePieChartSection(
    title: json['title'],
    value: json['value'],
    color: HexColor.fromHex(json['color'])
  );

}