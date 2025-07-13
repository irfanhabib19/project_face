import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DynamicHomePage extends StatelessWidget {
  final bool isDark;
  final List<String> forecast;

  const DynamicHomePage({
    super.key,
    required this.isDark,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Dynamic Weather Forecast'),
        backgroundColor: isDark ? Colors.teal[900] : Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "📊 5-Day Temperature Forecast",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.tealAccent : Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            "${forecast[spot.x.toInt()].split(":")[0]}\n${spot.y.toStringAsFixed(1)}°C",
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int index = value.toInt();
                          if (index >= 0 && index < forecast.length) {
                            return Text(
                              forecast[index].split(":")[0],
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text("");
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, _) => Text(
                          "${value.toInt()}°",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.tealAccent,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                      dotData: FlDotData(show: true),
                      spots: List.generate(forecast.length, (i) {
                        final temp = double.tryParse(
                              forecast[i].split(": ")[1].replaceAll("°C", ""),
                            ) ??
                            0;
                        return FlSpot(i.toDouble(), temp);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "🌦️ Weekly Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.purpleAccent : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.8,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(enabled: true),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: forecast
                          .map((f) =>
                              double.tryParse(
                                  f.split(": ")[1].replaceAll("°C", "")) ??
                              0)
                          .reduce((a, b) => a > b ? a : b) +
                      5,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int index = value.toInt();
                          if (index >= 0 && index < forecast.length) {
                            return Text(
                              forecast[index].split(":")[0],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            );
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(forecast.length, (i) {
                    final temp = double.tryParse(
                          forecast[i].split(": ")[1].replaceAll("°C", ""),
                        ) ??
                        0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: temp,
                          color: Colors.deepPurpleAccent,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 50,
                            color: Colors.deepPurple.withOpacity(0.1),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
