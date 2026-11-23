class SubscriptionPlan {
  const SubscriptionPlan({
    required this.planName,
    required this.levelLabel,
    required this.masteryPercent,
    required this.fanProgress,
  });

  final String planName;
  final String levelLabel;
  final int masteryPercent;
  final List<FanMastery> fanProgress;
}

class FanMastery {
  const FanMastery({required this.fan, required this.percent});

  final String fan;
  final int percent;
}

const demoSubscription = SubscriptionPlan(
  planName: 'Standart obuna',
  levelLabel: 'O‘rta daraja',
  masteryPercent: 52,
  fanProgress: [
    FanMastery(fan: 'Matematika', percent: 68),
    FanMastery(fan: 'Fizika', percent: 45),
    FanMastery(fan: 'Ona tili', percent: 61),
  ],
);

const demoSubscriptions = <String>[
  'Matematika tayyorlov kanali',
  'Ustoz Sarvar — fizika',
];