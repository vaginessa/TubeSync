import 'package:isar/isar.dart';

part 'preferences.g.dart';

enum Preference { materialYou }

@collection
class Preferences {
  @Id()
  final String key;

  String? stringValue;
  int? intValue;
  double? doubleValue;
  bool? boolValue;
  String? dateTimeValue;

  Preferences(this.key);

  void set(dynamic value) {
    switch (value.runtimeType) {
      case const (String):
        stringValue = value;
        break;
      case const (int):
        intValue = value;
        break;
      case const (double):
        doubleValue = value;
        break;
      case const (bool):
        boolValue = value;
        break;
      default:
        throw UnsupportedError('${value.runtimeType} is not supported');
    }
  }

  T get<T>() {
    return (stringValue ?? intValue ?? doubleValue ?? boolValue) as T;
  }
}

extension PreferenceExtension on IsarCollection<String, Preferences> {
  void setValue(Preference key, dynamic value) {
    final preference = Preferences(key.name)..set(value);

    isar.writeAsyncWith(preference, (db, data) => db.preferences.put(data));
  }

  T getValue<T>(Preference key, T defaultValue) {
    return get(key.name)?.get<T>() ?? defaultValue;
  }
}
