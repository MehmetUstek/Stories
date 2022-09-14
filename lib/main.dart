import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stories/data.dart';
import 'package:stories/models/story_model.dart';
import 'package:stories/story_view.dart';
import 'package:story/story_page_view/story_page_view.dart';
import 'package:video_player/video_player.dart';
import 'models/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(users: users),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<User> users;

  const HomePage({required this.users});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('show stories'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StoryPage();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class StoryPage extends StatefulWidget {
  StoryPage({Key? key}) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
    Story? story = users.first.userStories?.first;
    if (story?.storyType == StoryType.video) {
      _videoController?.dispose();

      _videoController = VideoPlayerController.network(story!.URL)
        ..initialize().then((_) {
          setState(() {});
          if (_videoController!.value.isInitialized) {
            _videoController!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int details) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryPageView(
        initialPage: 0,
        onPageChanged: (details) => _onPageChanged(details),
        itemBuilder: (context, pageIndex, storyIndex) {
          final user = users[pageIndex];
          final story = user.userStories![storyIndex];
          Widget content = const SizedBox.shrink();
          switch (story.storyType) {
            case StoryType.image:
              content = Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: story.URL,
                  fit: BoxFit.cover,
                ),
              );
              break;
            case StoryType.video:
              if (_videoController != null &&
                  _videoController!.value.isInitialized) {
                content = FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                );
              }
              break;
            default:
              content = const SizedBox.shrink();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              content,
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user.userIconURL),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ]);
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          if (pageIndex == 0) {
            return 1;
          }
          return 0;
        },
        pageLength: users.length,
        storyLength: (int pageIndex) {
          return users[pageIndex].userStories!.length;
        },
        onPageLimitReached: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
