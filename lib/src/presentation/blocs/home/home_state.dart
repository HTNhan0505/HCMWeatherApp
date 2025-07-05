abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<String> images;
  final Map<String, dynamic> weather;
  HomeLoaded({required this.images, required this.weather});
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
} 