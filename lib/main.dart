import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/presentation/blocs/home/home_bloc.dart';
import 'src/presentation/screens/home_screen.dart';
import 'src/data/datasources/image_remote_datasource.dart';
import 'src/data/datasources/weather_remote_datasource.dart';
import 'src/presentation/blocs/home/home_event.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _requestPermissions();
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            imageDatasource: ImageRemoteDatasource(),
            weatherDatasource: WeatherRemoteDatasource(),
          )..add(LoadHomeData()),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future<void> _requestPermissions() async {
  await Permission.storage.request();
  await Permission.photos.request();
}
