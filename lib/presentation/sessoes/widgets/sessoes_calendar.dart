// lib/presentation/sessoes/widgets/sessoes_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SessoesCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, String> dailyStatus;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final VoidCallback onTodayButtonPressed;

  const SessoesCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.dailyStatus,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onTodayButtonPressed,
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
      daysOfWeekStyle: const DaysOfWeekStyle(
        // Deixa os dias de semana (Seg-Sex) em negrito
        weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
        // Deixa os fins de semana (Sab-Dom) em negrito
        weekendStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        headerPadding: EdgeInsets.symmetric(vertical: 4.0),
        leftChevronPadding: EdgeInsets.all(4.0),
        rightChevronPadding: EdgeInsets.all(4.0),
        titleTextStyle: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
        rightChevronIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão "Hoje" estilizado
            InkWell(
              onTap: onTodayButtonPressed,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // ADICIONE A COR DE FUNDO AQUI:
                  color: Colors.blue.shade300,
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // ADICIONE O ESTILO AO TEXTO AQUI:
                child: const Text(
                  'Hoje',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade300,
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
              color = Colors.green.shade200;
              break;
            case 'parcial':
              color = Colors.yellow.shade200;
              break;
            case 'cheio':
              color = Colors.red.shade200;
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
          final isSelected = isSameDay(day, selectedDay);
          return Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(6.0),
              border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
    );
  }
}