import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/broker_model.dart';
import '../../data/repositories/broker_repository.dart';

// --- EVENTOS ---
abstract class BrokerEvent {}

class LoadBrokers extends BrokerEvent {}

class AddBroker extends BrokerEvent {
  final Broker broker;
  AddBroker(this.broker);
}

class UpdateBroker extends BrokerEvent {
  final Broker broker;
  UpdateBroker(this.broker);
}

class RemoveBroker extends BrokerEvent {
  final String id;
  RemoveBroker(this.id);
}

// --- ESTADOS ---
class BrokerState {
  final List<Broker> brokers;
  final bool isLoading;

  BrokerState({this.brokers = const [], this.isLoading = false});

  BrokerState copyWith({List<Broker>? brokers, bool? isLoading}) {
    return BrokerState(
      brokers: brokers ?? this.brokers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- BLOC ---
class BrokerBloc extends Bloc<BrokerEvent, BrokerState> {
  final BrokerRepository repository;

  BrokerBloc(this.repository) : super(BrokerState()) {
    on<LoadBrokers>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final brokers = await repository.getBrokers();
      emit(state.copyWith(brokers: brokers, isLoading: false));
    });

    // Agregar nuevo
    on<AddBroker>((event, emit) async {
      await repository.saveBroker(event.broker);
      add(LoadBrokers());
    });

    on<UpdateBroker>((event, emit) async {
      await repository.saveBroker(event.broker);
      add(LoadBrokers());
    });

    on<RemoveBroker>((event, emit) async {
      await repository.deleteBroker(event.id);
      add(LoadBrokers());
    });
  }
}
