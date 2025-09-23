import 'package:intl/intl.dart';

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

  // NOVO MÉTODO: Converte uma string no formato "dd/MM/yyyy" para DateTime
  static DateTime parseDate(String dateString) {
    try {
      // Usa DateFormat para parsear a string de data
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      // Em caso de erro de parsing, relança a exceção para ser tratada
      // na camada superior (ex: no PacienteModel ou no ViewModel).
      throw FormatException('Erro ao parsear data "$dateString". Formato esperado: dd/MM/yyyy. Erro: $e');
    }
  }
  
  static String getCapitalizedWeekdayName(DateTime date) {
    String weekday = getWeekdayName(date); // ex: "segunda-feira"
    if (weekday.isEmpty) return "";
    return weekday[0].toUpperCase() + weekday.substring(1); // -> "Segunda-feira"
  }
}

