import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/broker_repository.dart';
import 'logic/blocs/broker_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final brokerRepository = BrokerRepository();
  runApp(MyApp(brokerRepository: brokerRepository));
}

class MyApp extends StatelessWidget {
  final BrokerRepository brokerRepository;

  const MyApp({super.key, required this.brokerRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BrokerBloc(brokerRepository)..add(LoadBrokers()),
        ),
      ],
      child: MaterialApp(
        title: 'ToquiQTT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
