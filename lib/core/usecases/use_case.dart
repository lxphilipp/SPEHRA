import 'package:equatable/equatable.dart';

/// Eine abstrakte Klasse, die als Vertrag für alle Use Cases in der App dient.
/// [Type] ist der Rückgabetyp des Use Case.
/// [Params] ist der Typ der Parameter, die der Use Case benötigt.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Eine Hilfsklasse, die verwendet wird, wenn ein Use Case keine Parameter benötigt.
/// z.B. bei einem einfachen Logout oder dem Abrufen aller Daten ohne Filter.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}