class SocialTask {
  final String title;
  int completed;
  final int target;
  final String reward;
  final String rewardImage;
  final bool isVip;

  SocialTask(
      this.title,
      this.completed,
      this.target, {
        required this.reward,
        required this.rewardImage,
        this.isVip = false,
      });

  double get progress => target > 0 ? completed / target : 0.0;
}