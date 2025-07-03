import 'package:intl/intl.dart'; // Adicione intl ao seu pubspec.yaml: dependencies: intl: ^0.18.0

// Utilitário para formatação de datas
class DateFormatter {
  // Formata um DateTime para o formato "dd/MM/yyyy"
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formata um DateTime para o formato "HH:mm"
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Formata um DateTime para o formato "dd/MM/yyyy HH:mm"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Retorna o dia da semana por extenso (ex: Segunda-feira)
  static String getWeekdayName(DateTime date) {
    Intl.defaultLocale = 'pt_BR'; // Define o locale para português do Brasil
    return DateFormat('EEEE').format(date);
  }
}

