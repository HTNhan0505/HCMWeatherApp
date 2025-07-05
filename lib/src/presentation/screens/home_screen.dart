import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';
import '../blocs/home/home_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/image_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            Widget weatherWidget;
            Widget gridWidget;

            if (state is HomeLoading) {
              weatherWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: 18,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 4),
                  ),
                  Container(
                    width: 40,
                    height: 18,
                    color: Colors.grey[300],
                  ),
                ],
              );
              gridWidget = GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              );
            } else if (state is HomeLoaded) {
              final images = state.images;
              final weather = state.weather;
              weatherWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather['location'] ?? ''} city',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    '${weather['temperature']?.toString() ?? '--'}°C',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              );
              gridWidget = RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeData());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: GridView.builder(
                  key: const PageStorageKey('home_grid'),
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final imgUrl = images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ImageViewerScreen(imageUrl: imgUrl),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is HomeError) {
              weatherWidget = const SizedBox.shrink();
              gridWidget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'There was a problem loading the image, please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(LoadHomeData());
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else {
              weatherWidget = const SizedBox.shrink();
              gridWidget = const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 24, right: 24, bottom: 0),
                  child: Center(
                    child: Text(
                      'Demo App',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8, left: 24, right: 24, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: weatherWidget,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: gridWidget,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
