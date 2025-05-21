import 'package:equatable/equatable.dart';

abstract class SavedDataState extends Equatable {
  const SavedDataState();

  @override
  List<Object?> get props => [];
}

class SavedDataInitial extends SavedDataState {}

class SavedDataLoading extends SavedDataState {}

class SavedDataLoaded extends SavedDataState {
  final String data;

  const SavedDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class SavedDataError extends SavedDataState {
  final String message;

  const SavedDataError(this.message);

  @override
  List<Object?> get props => [message];
}
