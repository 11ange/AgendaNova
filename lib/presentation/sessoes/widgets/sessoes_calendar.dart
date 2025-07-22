// lib/presentation/sessoes/widgets/sessoes_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SessoesCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, String> dailyStatus;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const SessoesCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.dailyStatus,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: CalendarFormat.month,
      locale: 'pt_BR',
      rowHeight: 30.0,
      daysOfWeekHeight: 15,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        headerPadding: EdgeInsets.symmetric(vertical: 4.0),
        leftChevronPadding: EdgeInsets.all(4.0),
        rightChevronPadding: EdgeInsets.all(4.0),
        titleTextStyle: TextStyle(fontSize: 17.0),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(6.0),
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final status = dailyStatus[DateUtils.dateOnly(day)];
          Color color;
          switch (status) {
            case 'livre':
              color = Colors.green.shade100;
              break;
            case 'parcial':
              color = Colors.blue.shade100;
              break;
            case 'cheio':
              color = Colors.red.shade100;
              break;
            case 'indisponivel':
              color = Colors.grey.shade200;
              break;
            default:
              color = Colors.transparent;
          }

          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              '${day.day}',
              style: isSameDay(day, selectedDay)
                  ? const TextStyle(color: Colors.white)
                  : const TextStyle(color: Colors.black),
            ),
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              '${day.day}',
              style: const TextStyle(color: Colors.black87),
            ),
          );
        },
      ),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
    );
  }
}