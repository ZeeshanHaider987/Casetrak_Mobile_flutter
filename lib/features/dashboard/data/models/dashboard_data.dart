class DashboardKpi {
  const DashboardKpi({
    required this.label,
    required this.value,
    this.footnote,
  });

  final String label;
  final String value;
  final String? footnote;
}

class DashboardDeadline {
  const DashboardDeadline({
    required this.id,
    required this.matterId,
    required this.title,
    required this.dueOn,
  });

  final String id;
  final String matterId;
  final String title;
  final DateTime dueOn;
}

class DashboardActivity {
  const DashboardActivity({
    required this.id,
    required this.matterId,
    required this.title,
    required this.detail,
    required this.at,
  });

  final String id;
  final String matterId;
  final String title;
  final String detail;
  final DateTime at;
}

class DashboardData {
  const DashboardData({
    required this.kpis,
    required this.deadlines,
    required this.activity,
  });

  final List<DashboardKpi> kpis;
  final List<DashboardDeadline> deadlines;
  final List<DashboardActivity> activity;
}
