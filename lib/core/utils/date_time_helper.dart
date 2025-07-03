// Utilitário para manipulação de datas e horas
class DateTimeHelper {
  // Retorna o próximo DateTime que corresponde ao dia da semana especificado
  // (ex: se hoje é terça e você pede "quinta", retorna a próxima quinta-feira).
  // Se a data de início já for o dia da semana desejado, retorna a própria data de início.
  static DateTime getNextWeekday(DateTime startDate, String weekdayName) {
    final Map<String, int> weekdayMap = {
      'Segunda-feira': DateTime.monday,
      'Terça-feira': DateTime.tuesday,
      'Quarta-feira': DateTime.wednesday,
      'Quinta-feira': DateTime.thursday,
      'Sexta-feira': DateTime.friday,
      'Sábado': DateTime.saturday,
      'Domingo': DateTime.sunday,
    };

    final targetWeekday = weekdayMap[weekdayName];
    if (targetWeekday == null) {
      throw ArgumentError('Nome do dia da semana inválido: $weekdayName');
    }

    DateTime date = DateTime(startDate.year, startDate.month, startDate.day);
    while (date.weekday != targetWeekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}

