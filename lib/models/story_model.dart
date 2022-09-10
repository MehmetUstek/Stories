import 'package:stories/models/user_model.dart';

enum StoryType { image, video }

class Story {
  final String URL;
  final StoryType storyType;
  final Duration duration;
  final User user;

  Story(
      {required this.URL,
      required this.storyType,
      required this.duration,
      required this.user});
}
