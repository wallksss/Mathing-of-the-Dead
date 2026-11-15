// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mathing of the Dead';

  @override
  String get tagline =>
      'Convierte la matrícula de cada zombi en una igualdad verdadera antes de que te alcance.';

  @override
  String get developedBy => 'Desarrollado por';

  @override
  String get professorCredit => 'Basado en Emplake, del Prof. Walter Carnielli';

  @override
  String get language => 'Idioma';

  @override
  String get languageName => 'Español';

  @override
  String get firebaseMissingTitle => 'Firebase no está configurado';

  @override
  String get firebaseMissingBody =>
      'Ejecuta \"flutterfire configure\" para generar lib/firebase_options.dart y reinicia la aplicación.';

  @override
  String firebaseErrorBody(String error) {
    return 'No se pudo conectar a Firebase: $error';
  }

  @override
  String get navPlay => 'Jugar';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navHistory => 'Cementerio';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navHelp => 'Ayuda';

  @override
  String get helpTitle => 'Cómo sobrevivir';

  @override
  String get helpGoalTitle => 'Objetivo';

  @override
  String get helpGoalBody =>
      'Cada zombi lleva una matrícula con cuatro dígitos. Mantén los dígitos en orden y añade operadores y un \"=\" para formar una igualdad verdadera. Ejemplo: 8 1 3 1 → √(8 + 1) = 3**1.';

  @override
  String get helpBuildTitle => 'Cargando la matrícula';

  @override
  String get helpBuildBody =>
      'Toca un hueco entre los dígitos para apuntar (el cursor brillante) y luego toca los operadores del cinturón de munición. Toca un operador de la matrícula para quitarlo. Los dígitos nunca se pueden unir: 1 2 no es doce.';

  @override
  String get helpKeyboardTitle => 'Teclado (¡typing of the dead!)';

  @override
  String get helpKeyboardBody =>
      'Escribe + - * / ( ) ! = directamente. ** o ^ es potencia, s es √, c es ∛, | es el valor absoluto, [ ] es el piso y { } es el techo. Escribir el siguiente dígito solo lo salta. ← → mueven el cursor, Retroceso borra, Enter dispara y Esc limpia.';

  @override
  String get helpLevelsTitle => 'Niveles';

  @override
  String get helpLevelsBody =>
      'Fácil tiene todos los operadores y es el único nivel que acepta divisiones no enteras como 5/2. Intermedio quita piso y techo, Avanzado también quita la potencia y la raíz cúbica, y Difícil solo conserva + - × ÷, paréntesis y el valor absoluto.';

  @override
  String get helpScoreTitle => 'Puntuación';

  @override
  String get helpScoreBody =>
      'Los niveles más difíciles valen más puntos. Responder rápido y mantener una racha da bonificaciones. Una pista cuesta el 75% de los puntos de la matrícula. Puedes saltar una matrícula en cualquier momento, y una matrícula resuelta nunca vuelve a aparecer en ese nivel.';

  @override
  String get close => 'Cerrar';

  @override
  String get chooseBattle => 'Elige tu batalla';

  @override
  String welcomeBack(String name) {
    return '¡Bienvenido(a) de nuevo, $name!';
  }

  @override
  String get totalScore => 'Puntuación total';

  @override
  String get platesSolved => 'Matrículas resueltas';

  @override
  String get bestStreak => 'Mejor racha';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelEasyDesc =>
      'Todo el arsenal, incluidos piso, techo y división no entera.';

  @override
  String get levelIntermediateDesc =>
      'Raíces, potencias y factoriales. Las divisiones deben ser exactas.';

  @override
  String get levelAdvancedDesc =>
      'Solo raíz cuadrada y factorial. Las divisiones deben ser exactas.';

  @override
  String get levelHardDesc =>
      'Solo las cuatro operaciones, paréntesis y el valor absoluto.';

  @override
  String pointsPerPlate(int points) {
    return '$points pts por matrícula';
  }

  @override
  String solvedAtLevel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matrículas resueltas',
      one: '1 matrícula resuelta',
      zero: 'Ninguna matrícula resuelta aún',
    );
    return '$_temp0';
  }

  @override
  String get startLevel => 'Luchar';

  @override
  String get loadingGraveyard => 'Desenterrando matrículas sin resolver…';

  @override
  String loadError(String error) {
    return 'No se pudieron cargar tus datos: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get score => 'Puntos';

  @override
  String streak(int count) {
    return 'Racha ×$count';
  }

  @override
  String livesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vidas restantes',
      one: '1 vida restante',
    );
    return '$_temp0';
  }

  @override
  String get zenMode => 'Modo zen: el zombi te espera';

  @override
  String get fire => '¡Fuego!';

  @override
  String get clear => 'Limpiar';

  @override
  String get skip => 'Saltar';

  @override
  String get hint => 'Pista';

  @override
  String get backToLevels => 'Volver a los niveles';

  @override
  String get soundOn => 'Activar sonido';

  @override
  String get soundOff => 'Desactivar sonido';

  @override
  String get aimHint =>
      'Toca un hueco para apuntar · toca un operador para cargarlo';

  @override
  String get latexPreview => 'Vista previa en LaTeX';

  @override
  String get yourEquation => 'Tu ecuación';

  @override
  String plateLabel(String number) {
    return 'Matrícula $number';
  }

  @override
  String get hintTitle => 'El oráculo susurra…';

  @override
  String get hintCost =>
      'Usar una pista reduce la recompensa de esta matrícula en un 75%.';

  @override
  String get hintThinking => 'Consultando al oráculo…';

  @override
  String get hintNone =>
      'Ni el oráculo encontró una respuesta. Puede ser una de las matrículas realmente difíciles: considera saltarla.';

  @override
  String get showHint => 'Revelar';

  @override
  String get cancel => 'Cancelar';

  @override
  String headshot(int points) {
    return '¡Tiro a la cabeza! +$points';
  }

  @override
  String get zombieGotYou => '¡El zombi te atrapó!';

  @override
  String get possibleSolution => 'Una solución posible:';

  @override
  String get noKnownSolution => 'No se encontró solución para esta matrícula.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get gameOver => 'Fin del juego';

  @override
  String finalScore(int score) {
    return 'Puntos de la partida: $score';
  }

  @override
  String platesThisRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matrículas en esta partida',
      one: '1 matrícula en esta partida',
      zero: 'Ninguna matrícula en esta partida',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get allSolved =>
      'Has resuelto todas las matrículas de este nivel. ¡Legendario!';

  @override
  String get skipped => 'Matrícula saltada';

  @override
  String saveFailed(String error) {
    return 'No se pudo guardar tu progreso: $error';
  }

  @override
  String valuesDiffer(String left, String right) {
    return 'Los lados son distintos: $left ≠ $right';
  }

  @override
  String get errEmptyPlate => 'La matrícula está vacía.';

  @override
  String get errMissingEquals => 'Añade un signo \"=\".';

  @override
  String get errMultipleEquals => 'Usa un solo signo \"=\".';

  @override
  String get errEmptySide => 'Ambos lados del \"=\" necesitan dígitos.';

  @override
  String get errMissingOperator => 'Dos números sin operador entre ellos.';

  @override
  String get errUnexpectedToken => 'Este operador está en el lugar equivocado.';

  @override
  String get errMissingOperand => 'A este operador le falta un número.';

  @override
  String get errUnclosedBracket => 'Este paréntesis (o barra) nunca se cerró.';

  @override
  String get errUnmatchedClose =>
      'Este cierre no cierra nada (o cierra el tipo equivocado).';

  @override
  String get errOperatorNotAllowed =>
      'Este operador no está permitido en este nivel.';

  @override
  String get errDivisionByZero => 'División por cero.';

  @override
  String get errNonIntegerDivision =>
      'En este nivel solo se permiten divisiones exactas (enteras).';

  @override
  String get errNegativeSqrt => 'Raíz cuadrada de un número negativo.';

  @override
  String get errFactorialNotInteger =>
      'El factorial solo funciona con números enteros.';

  @override
  String get errFactorialNegative => 'Factorial de un número negativo.';

  @override
  String get errFactorialTooLarge => 'Ese factorial es demasiado grande.';

  @override
  String get errPowerUndefined => 'Esta potencia no está definida.';

  @override
  String get errOutOfRange =>
      'El resultado es demasiado grande o demasiado pequeño.';

  @override
  String get opPlus => 'Suma';

  @override
  String get opMinus => 'Resta o signo negativo';

  @override
  String get opTimes => 'Multiplicación';

  @override
  String get opDivide => 'División';

  @override
  String get opLparen => 'Abrir paréntesis';

  @override
  String get opRparen => 'Cerrar paréntesis';

  @override
  String get opPower => 'Potencia (**)';

  @override
  String get opSqrt => 'Raíz cuadrada';

  @override
  String get opCbrt => 'Raíz cúbica';

  @override
  String get opFactorial => 'Factorial';

  @override
  String get opAbs => 'Valor absoluto';

  @override
  String get opFloor => 'Piso';

  @override
  String get opCeil => 'Techo';

  @override
  String get opEquals => 'Signo igual';

  @override
  String get rankingTitle => 'Salón de los Supervivientes';

  @override
  String get rankingEmpty => 'Aún no hay supervivientes. ¡Sé el primero!';

  @override
  String get you => 'Tú';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String platesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matrículas',
      one: '1 matrícula',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'Cementerio de matrículas resueltas';

  @override
  String get historyEmpty => 'Aún no has resuelto matrículas. La horda espera.';

  @override
  String get allLevels => 'Todos';

  @override
  String get withHint => 'con pista';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themePresets => 'Temas listos';

  @override
  String get presetClassic => 'Clásico';

  @override
  String get presetToxic => 'Tóxico';

  @override
  String get presetBloodMoon => 'Luna de sangre';

  @override
  String get presetMidnight => 'Medianoche';

  @override
  String get presetFog => 'Niebla del cementerio';

  @override
  String get presetPumpkin => 'Calabaza';

  @override
  String get seedColor => 'Color semilla';

  @override
  String get customColor => 'Color personalizado';

  @override
  String get hue => 'Tono';

  @override
  String get saturation => 'Saturación';

  @override
  String get fontFamily => 'Fuente';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String get fontPreview => 'El zombi veloz resuelve 8 1 3 1.';

  @override
  String get game => 'Juego';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get soundEffectsDesc =>
      'Desactivados por defecto. Disparos, gemidos y campanas.';

  @override
  String get zombieSpeed => 'Velocidad de los zombis';

  @override
  String get speedOff => 'Zen';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rápida';

  @override
  String get account => 'Cuenta';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get nickname => 'Apodo mostrado en el ranking';

  @override
  String get save => 'Guardar';

  @override
  String get nicknameSaved => 'Apodo guardado';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get resetSettings => 'Restaurar ajustes predeterminados';

  @override
  String get anonymousSurvivor => 'Superviviente anónimo';
}
