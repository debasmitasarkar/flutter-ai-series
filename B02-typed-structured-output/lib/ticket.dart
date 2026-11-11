/// One schema, written once, sent to both providers.
/// Stays inside the subset both accept: no minLength/maxLength,
/// no minimum/maximum, every object closed with additionalProperties: false.
const ticketSchema = <String, Object?>{
  'type': 'object',
  'properties': {
    'summary': {
      'type': 'string',
      'description': 'One sentence, under 100 characters.',
    },
    'category': {
      'type': 'string',
      'enum': ['bug', 'billing', 'account', 'feature_request', 'other'],
    },
    'priority': {
      'type': 'string',
      'enum': ['low', 'medium', 'high', 'urgent'],
    },
    'platform': {
      'type': 'string',
      'enum': ['ios', 'android', 'web', 'unknown'],
    },
    'steps': {
      'type': 'array',
      'items': {'type': 'string'},
      'description': 'Steps to reproduce. Empty if none were given.',
    },
  },
  'required': ['summary', 'category', 'priority', 'platform', 'steps'],
  'additionalProperties': false,
};

enum Category { bug, billing, account, featureRequest, other }

enum Priority { low, medium, high, urgent }

enum Platform { ios, android, web, unknown }

class TicketDraft {
  const TicketDraft({
    required this.summary,
    required this.category,
    required this.priority,
    required this.platform,
    required this.steps,
  });

  final String summary;
  final Category category;
  final Priority priority;
  final Platform platform;
  final List<String> steps;

  /// The schema got us the right shape. This checks the things
  /// a schema can't promise: lengths, and values we can act on.
  factory TicketDraft.fromJson(Map<String, Object?> json) {
    final summary = json['summary'];
    if (summary is! String || summary.trim().isEmpty) {
      throw const FormatException('summary missing');
    }
    final steps = json['steps'];
    if (steps is! List || steps.any((s) => s is! String)) {
      throw const FormatException('steps must be a list of strings');
    }
    return TicketDraft(
      summary: summary.length > 100 ? '${summary.substring(0, 99)}…' : summary,
      category: switch (json['category']) {
        'bug' => Category.bug,
        'billing' => Category.billing,
        'account' => Category.account,
        'feature_request' => Category.featureRequest,
        'other' => Category.other,
        final v => throw FormatException('unknown category $v'),
      },
      priority: Priority.values.byName(_enum(json, 'priority')),
      platform: Platform.values.byName(_enum(json, 'platform')),
      steps: steps.cast<String>(),
    );
  }

  static String _enum(Map<String, Object?> json, String key) {
    final v = json[key];
    if (v is! String) throw FormatException('$key missing');
    return v;
  }
}
