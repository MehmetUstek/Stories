import 'package:stories/models/user_model.dart';

enum StoryType { image, video }

class Story {
  final String URL;
  final StoryType storyType;
  final Duration duration;

  Story({required this.URL, required this.storyType, required this.duration});
}
