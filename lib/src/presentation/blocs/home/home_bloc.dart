import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/image_remote_datasource.dart';
import '../../../data/datasources/weather_remote_datasource.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ImageRemoteDatasource imageDatasource;
  final WeatherRemoteDatasource weatherDatasource;

  HomeBloc({
    required this.imageDatasource,
    required this.weatherDatasource,
  }) : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final images = await imageDatasource.fetchImages();
        final weatherList = await weatherDatasource.fetchWeatherList();
        final weather =
            weatherList.firstWhere((w) => w["location"] == "Ho Chi Minh");
        emit(HomeLoaded(images: images, weather: weather));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
