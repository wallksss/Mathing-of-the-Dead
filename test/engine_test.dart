import 'package:flutter_test/flutter_test.dart';
import 'package:mathing_of_the_dead/game/engine/ast.dart';
import 'package:mathing_of_the_dead/game/engine/difficulty.dart';
import 'package:mathing_of_the_dead/game/engine/parser.dart';
import 'package:mathing_of_the_dead/game/engine/solver.dart';

CheckResult check(String plain, [Difficulty level = Difficulty.easy]) =>
    checkPlate(tokensFromPlain(plain), level);

void main() {
  group('checkPlate', () {
    test('examples from the assignment', () {
      expect(check('s(8+1)=3**1').isCorrect, isTrue);
      expect(check('(5-2)!=6*1').isCorrect, isTrue);
      expect(check('3*2=3+3', Difficulty.hard).isCorrect, isTrue);
    });

    test('precedence rules from the professor (17/11)', () {
      expect(check('1+2*3=7').isCorrect, isTrue);
      expect(check('s8!+0=1+1').isCorrect, isTrue); // (√8)! = 2! = 2
      expect(check('2*3!=8+4').isCorrect, isTrue);
      expect(check('-2+2=0+0').isCorrect, isTrue);
      expect(check('--2+0!=3+0').isCorrect, isTrue);
      expect(check('-(-2+5)=4-7').isCorrect, isTrue);
      expect(check('s9!=6*1', Difficulty.advanced).isCorrect, isTrue);
      expect(check('s(9!)=6*1').error!.code, MathErrorCode.notEqual);
    });

    test('factorial of huge or invalid values is a game error', () {
      for (final e in ['(9**9**9)!=9', '(9**9**9**9)!=9', '(s(9**9**9))!=9']) {
        expect(() => check(e), returnsNormally, reason: e);
        expect(check(e).isCorrect, isFalse, reason: e);
      }
    });

    test('compound expressions are accepted', () {
      for (final e in [
        '--(c(-(3!-s(8)))+7!!)=c(s(8!))',
        's(s(-(2-6)!!)!)=(s8)*1!',
        '-(-|-2|)=2*1',
        '((((2))))=2*1',
      ]) {
        final code = check(e).error?.code;
        expect(
          code,
          anyOf(
            isNull,
            MathErrorCode.notEqual,
            MathErrorCode.factorialNegative,
            MathErrorCode.factorialTooLarge,
          ),
          reason: e,
        );
      }
    });

    test('LaTeX keeps the root/factorial grouping', () {
      expect(check('s9!=6*1').equation!.toLatex(), r'\sqrt{9}! = 6 \times 1');
      expect(plateToLatex(tokensFromPlain('s(9!)=6')), r'\sqrt{9!} = 6');
    });

    test('LaTeX rendering', () {
      final r = check('s(8+1)=3**1');
      expect(r.equation!.toLatex(), r'\sqrt{8 + 1} = 3^{1}');
      expect(plateToLatex(tokensFromPlain('8/2=4')), r'\frac{8}{2} = 4');
    });

    test('fractional division only on easy', () {
      expect(check('5/2=5/2').isCorrect, isTrue);
      expect(
        check('5/2=5/2', Difficulty.intermediate).error!.code,
        MathErrorCode.nonIntegerDivision,
      );
      expect(check('8/2=4*1', Difficulty.hard).isCorrect, isTrue);
    });

    test('floor, ceil and abs', () {
      expect(check('[5/2]=2*1').isCorrect, isTrue);
      expect(
        check('{5/2]=3', Difficulty.easy).error!.code,
        MathErrorCode.unmatchedClose,
      );
      expect(check('{5/2}=3*1').isCorrect, isTrue);
      expect(check('|2-5|=3*1').isCorrect, isTrue);
      expect(check('-(2-5)=3*1', Difficulty.hard).isCorrect, isTrue);
    });

    test('operators restricted per level', () {
      expect(
        check('s9=3*1', Difficulty.hard).error!.code,
        MathErrorCode.operatorNotAllowed,
      );
      expect(
        check('c8=2*1', Difficulty.advanced).error!.code,
        MathErrorCode.operatorNotAllowed,
      );
      expect(check('s9=3*1', Difficulty.advanced).isCorrect, isTrue);
    });

    test('structural errors', () {
      expect(check('12=12').error!.code, MathErrorCode.missingOperator);
      expect(check('1+2+3+4').error!.code, MathErrorCode.missingEquals);
      expect(check('1=2=3').error!.code, MathErrorCode.multipleEquals);
      expect(check('=1').error!.code, MathErrorCode.emptySide);
      expect(check('(1+2=3').error!.code, MathErrorCode.unclosedBracket);
      expect(check('1+=3').error!.code, MathErrorCode.missingOperand);
      expect(check('1/0=1').error!.code, MathErrorCode.divisionByZero);
      expect(check('s(0-4)=2').error!.code, MathErrorCode.negativeSqrt);
      expect(check('1+2=4').error!.code, MathErrorCode.notEqual);
      // 120^-8 is tiny but is not zero.
      expect(check('7-7=5!**(-8)').isCorrect, isFalse);
      expect(check('s2*s2=2*1', Difficulty.intermediate).isCorrect, isTrue);
    });

    test('precedence', () {
      expect(check('-2**2=-4').isCorrect, isTrue);
      expect(check('2**3**2=512').isCorrect, isFalse); // 512 has 3 digits
      expect(check('2**3**2=8**3').isCorrect, isTrue);
      // √ applies only to the number after it: √9! = (√9)! ≠ √(9!).
      expect(check('s9!=s(9!)').isCorrect, isFalse);
      expect(check('s9!=(s9)!').isCorrect, isTrue);
      expect(check('-2!=-2').isCorrect, isTrue); // -(2!)
      expect(check('8-2-1=5').isCorrect, isTrue);
      expect(check('8/2/2=2').isCorrect, isTrue);
    });
  });

  group('solver', () {
    for (final level in Difficulty.values) {
      test('round-trips solutions on ${level.name}', () {
        const plates = ['8131', '1234', '5261', '0000', '9999', '2024', '7351'];
        var found = 0;
        for (final plate in plates) {
          final eq = solvePlate(plate, level);
          if (eq == null) continue;
          found++;
          final tokens = equationTokens(eq);
          final digits = tokens
              .map((t) => t.plain)
              .where((s) => RegExp(r'^\d$').hasMatch(s));
          expect(digits.join(), plate, reason: eq.toPlain());
          expect(
            checkPlate(tokens, level).isCorrect,
            isTrue,
            reason: '${eq.toPlain()} on $plate',
          );
        }
        expect(found, greaterThan(plates.length ~/ 2));
      });
    }
  });
}
