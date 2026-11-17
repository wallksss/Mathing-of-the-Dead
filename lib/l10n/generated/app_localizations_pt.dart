// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mathing of the Dead';

  @override
  String get tagline =>
      'Transforme a placa de cada zumbi em uma igualdade verdadeira antes que ele chegue até você.';

  @override
  String get developedBy => 'Desenvolvido por';

  @override
  String groupMember(int index, String name) {
    return 'Integrante $index — $name';
  }

  @override
  String get professorCredit => 'Baseado no Emplake, do Prof. Walter Carnielli';

  @override
  String get language => 'Idioma';

  @override
  String get languageName => 'Português';

  @override
  String get firebaseMissingTitle => 'O Firebase não está configurado';

  @override
  String get firebaseMissingBody =>
      'Execute \"flutterfire configure\" para gerar lib/firebase_options.dart e reinicie o aplicativo.';

  @override
  String firebaseErrorBody(String error) {
    return 'Não foi possível conectar ao Firebase: $error';
  }

  @override
  String get navPlay => 'Jogar';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navHistory => 'Cemitério';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get helpTitle => 'Como sobreviver';

  @override
  String get helpGoalTitle => 'Objetivo';

  @override
  String get helpGoalBody =>
      'Cada zumbi carrega uma placa com quatro dígitos. Mantenha os dígitos na ordem e acrescente operadores e um \"=\" para formar uma igualdade verdadeira. Exemplo: 8 1 3 1 → √(8 + 1) = 3**1.';

  @override
  String get helpBuildTitle => 'Carregando a placa';

  @override
  String get helpBuildBody =>
      'Toque em um espaço entre os dígitos para mirar (o cursor brilhante) e depois toque nos operadores do cinto de munição. Toque em um operador da placa para removê-lo. Dígitos nunca podem ser juntados: 1 2 não é doze.';

  @override
  String get helpKeyboardTitle => 'Teclado (typing of the dead!)';

  @override
  String get helpKeyboardBody =>
      'Digite + - * / ( ) ! = diretamente. ** ou ^ é potência, s é √, c é ∛, | é o módulo, [ ] é a base (piso) e { } é o teto. Digitar o próximo dígito apenas passa por ele. ← → movem o cursor, Backspace remove, Enter atira e Esc limpa.';

  @override
  String get helpLevelsTitle => 'Níveis';

  @override
  String get helpLevelsBody =>
      'O Fácil tem todos os operadores e é o único nível que aceita divisões não inteiras, como 5/2. O Intermediário remove base e teto, o Avançado também remove potência e raiz cúbica, e o Difícil mantém apenas + - × ÷, parênteses e o módulo.';

  @override
  String get helpScoreTitle => 'Pontuação';

  @override
  String get helpScoreBody =>
      'Níveis mais difíceis valem mais pontos. Responder rápido e manter uma sequência dá bônus. Uma dica custa 75% dos pontos da placa. Você pode pular uma placa a qualquer momento, mas o zumbi continua de onde estava, e uma placa resolvida nunca aparece de novo naquele nível.';

  @override
  String get close => 'Fechar';

  @override
  String get chooseBattle => 'Escolha sua batalha';

  @override
  String welcomeBack(String name) {
    return 'Bem-vindo(a) de volta, $name!';
  }

  @override
  String get totalScore => 'Pontuação total';

  @override
  String get platesSolved => 'Placas resolvidas';

  @override
  String get bestStreak => 'Melhor sequência';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelEasyDesc =>
      'O arsenal completo, incluindo base, teto e divisão não inteira.';

  @override
  String get levelIntermediateDesc =>
      'Raízes, potências e fatoriais. As divisões devem ser exatas.';

  @override
  String get levelAdvancedDesc =>
      'Apenas raiz quadrada e fatorial. As divisões devem ser exatas.';

  @override
  String get levelHardDesc => 'Só as quatro operações, parênteses e o módulo.';

  @override
  String pointsPerPlate(int points) {
    return '$points pts por placa';
  }

  @override
  String solvedAtLevel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas resolvidas',
      one: '1 placa resolvida',
      zero: 'Nenhuma placa resolvida ainda',
    );
    return '$_temp0';
  }

  @override
  String get startLevel => 'Lutar';

  @override
  String get loadingGraveyard => 'Desenterrando placas não resolvidas…';

  @override
  String loadError(String error) {
    return 'Não foi possível carregar seus dados: $error';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get score => 'Pontos';

  @override
  String streak(int count) {
    return 'Sequência ×$count';
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
  String get zenMode => 'Modo zen: o zumbi espera por você';

  @override
  String get fire => 'Atirar!';

  @override
  String get clear => 'Limpar';

  @override
  String get skip => 'Pular';

  @override
  String get hint => 'Dica';

  @override
  String get backToLevels => 'Voltar aos níveis';

  @override
  String get soundOn => 'Ligar o som';

  @override
  String get soundOff => 'Desligar o som';

  @override
  String get aimHint =>
      'Toque em um espaço para mirar · toque em um operador para carregá-lo';

  @override
  String get latexPreview => 'Visualização em LaTeX';

  @override
  String get yourEquation => 'Sua equação';

  @override
  String plateLabel(String number) {
    return 'Placa $number';
  }

  @override
  String get hintTitle => 'O oráculo sussurra…';

  @override
  String get hintCost => 'Usar uma dica reduz a recompensa desta placa em 75%.';

  @override
  String get hintThinking => 'Consultando o oráculo…';

  @override
  String get hintNone =>
      'Nem o oráculo encontrou uma resposta. Esta pode ser uma das placas realmente difíceis — considere pulá-la.';

  @override
  String get showHint => 'Revelar';

  @override
  String get cancel => 'Cancelar';

  @override
  String headshot(int points) {
    return 'Tiro na cabeça! +$points';
  }

  @override
  String get zombieGotYou => 'O zumbi te pegou!';

  @override
  String get possibleSolution => 'Uma solução possível:';

  @override
  String get noKnownSolution =>
      'Nenhuma solução foi encontrada para esta placa.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get gameOver => 'Fim de jogo';

  @override
  String finalScore(int score) {
    return 'Pontos da partida: $score';
  }

  @override
  String platesThisRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas nesta partida',
      one: '1 placa nesta partida',
      zero: 'Nenhuma placa nesta partida',
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Jogar de novo';

  @override
  String get allSolved =>
      'Você resolveu todas as placas deste nível. Lendário!';

  @override
  String get skipped => 'Placa pulada';

  @override
  String saveFailed(String error) {
    return 'Não foi possível salvar seu progresso: $error';
  }

  @override
  String valuesDiffer(String left, String right) {
    return 'Os lados são diferentes: $left ≠ $right';
  }

  @override
  String get errEmptyPlate => 'A placa está vazia.';

  @override
  String get errMissingEquals => 'Acrescente um sinal de \"=\".';

  @override
  String get errMultipleEquals => 'Use apenas um sinal de \"=\".';

  @override
  String get errEmptySide => 'Os dois lados do \"=\" precisam de dígitos.';

  @override
  String get errMissingOperator => 'Dois números sem operador entre eles.';

  @override
  String get errUnexpectedToken => 'Este operador está no lugar errado.';

  @override
  String get errMissingOperand => 'Falta um número para este operador.';

  @override
  String get errUnclosedBracket =>
      'Este parêntese (ou barra) nunca foi fechado.';

  @override
  String get errUnmatchedClose =>
      'Este fechamento não fecha nada (ou fecha o tipo errado).';

  @override
  String get errOperatorNotAllowed =>
      'Este operador não é permitido neste nível.';

  @override
  String get errDivisionByZero => 'Divisão por zero.';

  @override
  String get errNonIntegerDivision =>
      'Neste nível só são permitidas divisões exatas (inteiras).';

  @override
  String get errNegativeSqrt => 'Raiz quadrada de número negativo.';

  @override
  String get errFactorialNotInteger =>
      'O fatorial só funciona com números inteiros.';

  @override
  String get errFactorialNegative => 'Fatorial de número negativo.';

  @override
  String get errFactorialTooLarge => 'Esse fatorial é grande demais.';

  @override
  String get errPowerUndefined => 'Esta potência não está definida.';

  @override
  String get errOutOfRange => 'O resultado é grande ou pequeno demais.';

  @override
  String get opPlus => 'Adição';

  @override
  String get opMinus => 'Subtração ou sinal negativo';

  @override
  String get opTimes => 'Multiplicação';

  @override
  String get opDivide => 'Divisão';

  @override
  String get opLparen => 'Abre parêntese';

  @override
  String get opRparen => 'Fecha parêntese';

  @override
  String get opPower => 'Potência (**)';

  @override
  String get opSqrt => 'Raiz quadrada';

  @override
  String get opCbrt => 'Raiz cúbica';

  @override
  String get opFactorial => 'Fatorial';

  @override
  String get opAbs => 'Módulo';

  @override
  String get opFloor => 'Base (piso)';

  @override
  String get opCeil => 'Teto';

  @override
  String get opEquals => 'Sinal de igual';

  @override
  String get rankingTitle => 'Hall dos Sobreviventes';

  @override
  String get rankingEmpty => 'Nenhum sobrevivente ainda. Seja o primeiro!';

  @override
  String get you => 'Você';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String platesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count placas',
      one: '1 placa',
    );
    return '$_temp0';
  }

  @override
  String get historyTitle => 'Cemitério de placas resolvidas';

  @override
  String get historyEmpty =>
      'Nenhuma placa resolvida ainda. A horda está esperando.';

  @override
  String get allLevels => 'Todos';

  @override
  String get withHint => 'com dica';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themePresets => 'Temas prontos';

  @override
  String get presetClassic => 'Clássico';

  @override
  String get presetToxic => 'Tóxico';

  @override
  String get presetBloodMoon => 'Lua de sangue';

  @override
  String get presetMidnight => 'Meia-noite';

  @override
  String get presetFog => 'Névoa do cemitério';

  @override
  String get presetPumpkin => 'Abóbora';

  @override
  String get seedColor => 'Cor semente';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get hue => 'Matiz';

  @override
  String get saturation => 'Saturação';

  @override
  String get fontFamily => 'Fonte';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get fontPreview => 'O zumbi veloz resolve 8 1 3 1.';

  @override
  String get game => 'Jogo';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get soundEffectsDesc =>
      'Desligados por padrão. Tiros, gemidos e sinos.';

  @override
  String get zombieSpeed => 'Velocidade dos zumbis';

  @override
  String get speedOff => 'Zen';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rápida';

  @override
  String get account => 'Conta';

  @override
  String signedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get nickname => 'Apelido exibido no ranking';

  @override
  String get save => 'Salvar';

  @override
  String get nicknameSaved => 'Apelido salvo';

  @override
  String get signOut => 'Sair';

  @override
  String get resetSettings => 'Restaurar configurações padrão';

  @override
  String get anonymousSurvivor => 'Sobrevivente anônimo';
}
