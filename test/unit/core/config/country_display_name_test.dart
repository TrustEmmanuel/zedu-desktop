import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/config/countries.dart';

void main() {
  test('maps a sign-up country code to its name', () {
    expect(countryDisplayName('Za'), 'South Africa');
    expect(countryDisplayName('ZA'), 'South Africa');
    expect(countryDisplayName(' za '), 'South Africa');
    expect(countryDisplayName('ca'), 'Canada');
  });

  test('keeps a stored country name', () {
    expect(countryDisplayName('Nigeria'), 'Nigeria');
    expect(countryDisplayName('nigeria'), 'Nigeria');
    expect(countryDisplayName("Côte d'Ivoire"), "Côte d'Ivoire");
  });

  test('leaves an empty or unknown value unchanged', () {
    expect(countryDisplayName(''), '');
    expect(countryDisplayName('   '), '');
    expect(countryDisplayName('zz'), 'zz');
    expect(countryDisplayName('Atlantis'), 'Atlantis');
  });
}
