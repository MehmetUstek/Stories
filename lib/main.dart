import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoryScreen(users: users),
    );
  }
}

class StoryScreen extends StatefulWidget {
  final List<User> users;

  const StoryScreen({super.key, required this.users});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  late List<Story>? currentStories;
  List<Story>? allStories = <Story>[];
  late User currentUser;
  int _userIndex = 0;
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);
    final User firstUser = widget.users.first;
    currentUser = firstUser;
    currentStories = firstUser.userStories;
    for (User user in widget.users) {
      for (Story story in user.userStories!) {
        allStories?.add(story);
      }
    }

    final Story? firstStory = firstUser.userStories?.first;

    _loadStory(story: firstStory!, animateToPage: false);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (currentUser.currentStoryGroupIndex + 1 < currentStories!.length) {
            currentUser.currentStoryGroupIndex += 1;
            _loadStory(
                story: currentStories![currentUser.currentStoryGroupIndex]);
          } else {
            nextUserStory();
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
    final Story story = currentStories![currentUser.currentStoryGroupIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        onTapUp: (details) => _onTapUp(details, story),
        onPanStart: (details) => _onPanStart(details, story),
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentStories!.length,
              itemBuilder: (context, i) {
                final Story story = currentStories![i];
                switch (story.storyType) {
                  case StoryType.image:
                    return CachedNetworkImage(
                      imageUrl: story.url,
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
                              currentIndex: currentUser.currentStoryGroupIndex,
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

  /*
  // Goes to next Story Group if any other user exists. If not it goes to the first user and continues as a loop.
  // Designed as a loop in order to avoid exceptions.
  // Makes changes on _userIndex, currentUser, currentStories global variables.
   */
  void nextUserStory() {
    if (_userIndex + 1 < users.length) {
      _userIndex++;
      currentUser = widget.users[_userIndex];
      currentStories = currentUser.userStories;
      _loadStory(story: currentStories![currentUser.currentStoryGroupIndex]);
    } else {
      _userIndex = 0;
      currentUser = widget.users[_userIndex];
      currentStories = currentUser.userStories;
      currentUser.currentStoryGroupIndex = 0;
      _loadStory(story: currentStories![currentUser.currentStoryGroupIndex]);
    }
  }

  /*
  // Goes to previous Story Group if any other user exists.
  // Makes changes on _userIndex, currentUser, currentStories global variables.
   */
  void previousUserStory() {
    if (_userIndex - 1 >= 0) {
      _userIndex--;
      currentUser = widget.users[_userIndex];
      currentStories = currentUser.userStories;
      _loadStory(story: currentStories![currentUser.currentStoryGroupIndex]);
    }
  }

  /*
  // The moment drag movement starts, this function is called by the PageView.
  // If the drag movement started from the left of the screen, it will go to the previous story group.
  // If the drag movement started from the right of the screen, it will go to the next story group.
   */
  void _onPanStart(DragStartDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 2) {
      setState(() {
        if (currentUser != widget.users.first) {
          previousUserStory();
        }
      });
    } else if (dx > screenWidth / 2) {
      setState(() {
        nextUserStory();
      });
    }
  }

  /*
  // Rest and hold behavior implementation. If the user taps the screen, hold that clicking time.
  // Immediately stop the animation and video.
   */
  void _onTapDown(TapDownDetails details, Story story) {
    currentTime = DateTime.now();
    if (story.storyType == StoryType.video) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _animController.stop();
      } else {
        _videoController!.play();
        _animController.forward();
      }
    } else {
      _animController.stop();
    }
  }

  /*
  // If the user tapped on screen and hold more than 300 milliseconds, don't do anything since this was a
  // rest-and-hold state. Otherwise, it was a left and right click. In that case, move to the next story or
  // next story group based on the current state of the story progression.
   */
  void _onTapUp(TapUpDetails details, Story story) {
    _animController.forward();

    Duration tapWaitTime = DateTime.now().difference(currentTime);
    if (tapWaitTime < const Duration(milliseconds: 300)) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double dx = details.globalPosition.dx;

      if (dx < screenWidth / 3) {
        setState(() {
          if (currentUser.currentStoryGroupIndex - 1 >= 0) {
            currentUser.currentStoryGroupIndex -= 1;
            _loadStory(
                story: currentStories![currentUser.currentStoryGroupIndex]);
          } else {
            if (currentUser != widget.users.first) {
              previousUserStory();
            }
          }
        });
      } else if (dx > 2 * screenWidth / 3) {
        setState(() {
          if (currentUser.currentStoryGroupIndex + 1 < currentStories!.length) {
            currentUser.currentStoryGroupIndex += 1;
            _loadStory(
                story: currentStories![currentUser.currentStoryGroupIndex]);
          } else {
            nextUserStory();
          }
        });
      }
    } else {
      if (story.storyType == StoryType.video) {
        _videoController!.play();
      }
    }
  }

  /*
  // Handles animationController and videoController events based on the StoryType.
   */
  void _loadStory({required Story story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    switch (story.storyType) {
      case StoryType.image:
        _animController.duration = const Duration(seconds: imageDuration);
        _animController.forward();
        break;
      case StoryType.video:
        _videoController?.dispose();

        _videoController = VideoPlayerController.network(story.url)
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
        currentUser.currentStoryGroupIndex,
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
