String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime parseDateKey(String value) => DateTime.parse(value);
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
DateTime nextDay(DateTime value, [int count = 1]) =>
    DateTime(value.year, value.month, value.day + count);
List<DateTime> weekOf(DateTime date) {
  final start = nextDay(dateOnly(date), 1 - date.weekday);
  return List.generate(7, (index) => nextDay(start, index));
}

const weekdayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
const shortWeekdays = ['LU', 'MA', 'MI', 'JU', 'VI', 'SÁ', 'DO'];
const monthNames = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
const fullMonthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];
String shortDate(DateTime date) => '${date.day} ${monthNames[date.month - 1]}';
String friendlyDate(DateTime date) =>
    '${weekdayNames[date.weekday - 1]} ${shortDate(date)}';
String weightLabel(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
