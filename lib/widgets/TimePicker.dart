import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TimePickerUtils {
  /// Muestra un selector de hora global con AM/PM y textos personalizados.
  static Future<String?> mostrarSelectorHora(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en'),
          delegates: const [
            _CustomEnglishMaterialLocalizationsDelegate(),
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, // ⚠ importante para AM/PM
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime == null) return null;

    final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
    final minute = pickedTime.minute.toString().padLeft(2, '0');
    final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';

    return "$hour:$minute $period";
  }
}

// ----------------------------------------
// Localizations personalizadas
// ----------------------------------------
class CustomEnglishMaterialLocalizations extends DefaultMaterialLocalizations {
  @override
  String get timePickerDialHelpText => 'Seleccionar con reloj';

  @override
  String get dialModeButtonLabel => 'Modo reloj';

  @override
  String get okButtonLabel => 'Aceptar';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get inputTimeModeButtonLabel => 'Introducir hora';

  @override
  String get timePickerInputHelpText => 'Introduzca la hora';

  @override
  String get invalidTimeLabel => 'Introduce una hora válida';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get timePickerHourLabel => 'Hora';

  @override
  String get timePickerMinuteLabel => 'Minutos';
}

// Delegado
class _CustomEnglishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CustomEnglishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return Future.value(CustomEnglishMaterialLocalizations());
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}