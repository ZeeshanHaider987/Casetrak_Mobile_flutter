import 'matter.dart';

class MatterTimeRow {
  const MatterTimeRow({
    required this.id,
    required this.workedOn,
    required this.feeEarnerId,
    required this.description,
    required this.hours,
  });

  final String id;
  final DateTime workedOn;
  final String feeEarnerId;
  final String description;
  final double hours;
}

class MatterInvoiceRow {
  const MatterInvoiceRow({
    required this.id,
    required this.number,
    required this.issuedOn,
    required this.amount,
    required this.currencyCode,
    required this.status,
  });

  final String id;
  final String number;
  final DateTime issuedOn;
  final double amount;
  final String currencyCode;
  final String status;
}

class MatterExpenseRow {
  const MatterExpenseRow({
    required this.id,
    required this.expenseType,
    required this.incurredOn,
    required this.amount,
    required this.currencyCode,
    required this.description,
  });

  final String id;
  final String expenseType;
  final DateTime incurredOn;
  final double amount;
  final String currencyCode;
  final String description;
}

class MatterDocumentRow {
  const MatterDocumentRow({
    required this.id,
    required this.name,
    required this.addedOn,
    required this.kind,
  });

  final String id;
  final String name;
  final DateTime addedOn;
  final String kind;
}

class MatterCommunicationRow {
  const MatterCommunicationRow({
    required this.id,
    required this.channel,
    required this.subject,
    required this.at,
  });

  final String id;
  final String channel;
  final String subject;
  final DateTime at;
}

class MatterTimelineEvent {
  const MatterTimelineEvent({
    required this.id,
    required this.title,
    required this.detail,
    required this.at,
  });

  final String id;
  final String title;
  final String detail;
  final DateTime at;
}

class MatterDetail {
  const MatterDetail({
    required this.matter,
    required this.time,
    required this.invoices,
    required this.expenses,
    required this.documents,
    required this.communications,
    required this.timeline,
  });

  final Matter matter;
  final List<MatterTimeRow> time;
  final List<MatterInvoiceRow> invoices;
  final List<MatterExpenseRow> expenses;
  final List<MatterDocumentRow> documents;
  final List<MatterCommunicationRow> communications;
  final List<MatterTimelineEvent> timeline;
}
