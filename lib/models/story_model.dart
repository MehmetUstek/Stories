enum StoryType { image, video }

class Story {
  final String url;
  final StoryType storyType;

  Story({required this.url, required this.storyType});
}
