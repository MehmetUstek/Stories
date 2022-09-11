import 'package:cached_network_image/cached_network_image.dart';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter/material.dart';
import 'package:stories/data.dart';
import 'package:video_player/video_player.dart';

import 'models/story_model.dart';
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
      home: StoryScreen(users: users),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final List<User> users;

  const StoryScreen({required this.users});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  ValueNotifier? _pageNotifier;
  int _currentIndex = 0;
  late List<Story>? currentStories;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageNotifier = ValueNotifier(0.0);
    _animController = AnimationController(vsync: this);
    final User firstUser = widget.users.first;
    currentUser = firstUser;
    currentStories = firstUser.userStories;
    final Story? firstStory = firstUser.userStories?.first;

    _loadStory(story: firstStory!, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < currentStories!.length) {
            _currentIndex += 1;
            _loadStory(story: currentStories![_currentIndex]);
          } else {
            // Out of bounds - loop story
            // You can also Navigator.of(context).pop() here
            _currentIndex = 0;
            _loadStory(story: currentStories![_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _animController.dispose();
    _videoController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = currentStories![_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              // physics: NeverScrollableScrollPhysics(),
              itemCount: currentStories!.length,
              itemBuilder: (context, i) {
                final Story story = currentStories![i];
                switch (story.storyType) {
                  case StoryType.image:
                    return CachedNetworkImage(
                      imageUrl: story.URL,
                      fit: BoxFit.cover,
                    );
                  case StoryType.video:
                    if (_videoController != null &&
                        _videoController!.value.isInitialized) {
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController!.value.size.width,
                          height: _videoController!.value.size.height,
                          child: VideoPlayer(_videoController!),
                        ),
                      );
                    }
                }
                return const SizedBox.shrink();
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: <Widget>[
                  Row(
                    children: currentStories!
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            AnimatedBar(
                              animController: _animController,
                              position: i,
                              currentIndex: _currentIndex,
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.5,
                      vertical: 10.0,
                    ),
                    child: UserInfo(user: currentUser),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(story: currentStories![_currentIndex]);
        }
      });
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        if (_currentIndex + 1 < currentStories!.length) {
          _currentIndex += 1;
          _loadStory(story: currentStories![_currentIndex]);
        } else {
          // Out of bounds - loop story
          // You can also Navigator.of(context).pop() here
          _currentIndex = 0;
          _loadStory(story: currentStories![_currentIndex]);
        }
      });
    } else {
      if (story.storyType == StoryType.video) {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _animController.stop();
        } else {
          _videoController!.play();
          _animController.forward();
        }
      }
    }
  }

  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story.storyType) {
      case StoryType.image:
        _animController.duration = story.duration;
        _animController.forward();
        break;
      case StoryType.video:
        _videoController?.dispose();

        _videoController = VideoPlayerController.network(story.URL)
          ..initialize().then((_) {
            setState(() {});
            if (_videoController!.value.isInitialized) {
              _animController.duration = _videoController!.value.duration;
              _videoController!.play();
              _animController.forward();
            }
          });
        break;
    }
    if (animateToPage) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: CachedNetworkImageProvider(
            user.userIconURL,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            user.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
