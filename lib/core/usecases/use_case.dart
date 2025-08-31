import 'package:equatable/equatable.dart';

/// Eine abstrakte Klasse, die als Vertrag für alle Use Cases in der App dient.
/// [Type] ist der Rückgabetyp des Use Case.
/// [Params] ist der Typ der Parameter, die der Use Case benötigt.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// A class that represents no parameters for a use case.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}