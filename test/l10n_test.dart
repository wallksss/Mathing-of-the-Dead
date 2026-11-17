import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mathing_of_the_dead/config/app_config.dart';
import 'package:mathing_of_the_dead/l10n/generated/app_localizations.dart';

void main() {
  test('group members are labelled in the chosen language', () {
    final name = AppConfig.groupMembers.first;
    expect(name, isNot(contains('Integrante')));
    final pt = lookupAppLocalizations(const Locale('pt'));
    final en = lookupAppLocalizations(const Locale('en'));
    final es = lookupAppLocalizations(const Locale('es'));
    expect(pt.groupMember(1, name), 'Integrante 1 — $name');
    expect(en.groupMember(1, name), 'Member 1 — $name');
    expect(es.groupMember(1, name), 'Integrante 1 — $name');
  });
}
