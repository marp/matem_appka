import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:matem_appka/model/game_session.dart';
import 'package:matem_appka/services/activity_service.dart';

import '../const/colors.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final ActivityService _activityService = ActivityService();

  Map<DateTime, List<GameSession>> _sessionsByDay = {};
  List<GameSession> _selectedDaySessions = [];
  List<double> _weeklyXp = List<double>.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final byDay = _activityService.sessionsByDayInRange(startOfMonth, endOfMonth);
    final selected = _selectedDay ?? _focusedDay;

    final sessionsForSelected = _activityService.sessionsForDay(selected);
    final weeklyXp = _activityService
        .xpForLast7Days()
        .map((e) => e.toDouble())
        .toList(growable: false);

    setState(() {
      _sessionsByDay = byDay;
      _selectedDaySessions = sessionsForSelected;
      _weeklyXp = weeklyXp;
    });
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text("Overview", style: headerText),
                  _buildSummaryRow(),
                  const SizedBox(height: 8),
                  Text("Daily activities", style: headerText),
                  _buildCalendarCard(),
                  const SizedBox(height: 8),
                  _buildDaySessionsList(),
                  const SizedBox(height: 8),
                  Text("Experience", style: headerText),
                  _buildWeeklyActivityChart(),
                  // const SizedBox(height: 24),
                  // _buildCategoryPieChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) =>
              _selectedDay != null &&
              day.year == _selectedDay!.year &&
              day.month == _selectedDay!.month &&
              day.day == _selectedDay!.day,
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
          eventLoader: (day) {
            final key = _dayOnly(day);
            return _sessionsByDay[key] ?? const <GameSession>[];
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedDaySessions =
                  _activityService.sessionsForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _loadActivityData();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final todayXp = _activityService.xpForDay(DateTime.now());
    final currentStreak = _activityService.currentStreak;
    final bestStreak = _activityService.bestStreak;

    return  Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'XP earned today',
              value: '$todayXp',
              subtitle: 'Keep it up!',
              color: Colors.blue,
              icon: Icons.bolt_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Current streak',
              value: '$currentStreak',
              subtitle: 'Best: $bestStreak days',
              color: Colors.orange,
              icon: Icons.local_fire_department_outlined,
            ),
          ),
        ],
      );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityChart() {
    final maxY = _weeklyXp.isEmpty
        ? 10.0
        : (_weeklyXp.reduce((a, b) => a > b ? a : b) * 1.2).clamp(10.0, 500.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly XP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 30),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final index = value.toInt();
                            if (index < 0 || index >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(days[index],
                                style: const TextStyle(fontSize: 11));
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: primaryColor,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                        spots: [
                          for (int i = 0; i < 7; i++)
                            FlSpot(i.toDouble(),
                                i < _weeklyXp.length ? _weeklyXp[i] : 0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySessionsList() {
    if (_selectedDaySessions.isEmpty) {
      return const  Text('No games on this day yet.');
    }

    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedDaySessions.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = _selectedDaySessions[index];
            final time = TimeOfDay.fromDateTime(s.playedAt).format(context);
            return ListTile(
              leading: const Icon(Icons.videogame_asset_outlined),
              title: Text('${s.gameType} · $time'),
              subtitle: Text('XP: ${s.xpEarned}  •  Score: ${s.score}'),
            );
          },
        ),
      );
  }
}
