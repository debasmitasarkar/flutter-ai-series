import 'package:flutter/material.dart';

import 'clients.dart';
import 'ticket.dart';

class TicketSheet extends StatefulWidget {
  const TicketSheet({super.key, required this.client, required this.message});
  final StructuredClient client;
  final String message;

  @override
  State<TicketSheet> createState() => _TicketSheetState();
}

class _TicketSheetState extends State<TicketSheet> {
  late final Future<TicketDraft> _draft = widget.client
      .extract(widget.message, schema: ticketSchema)
      .then(TicketDraft.fromJson);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TicketDraft>(
      future: _draft,
      builder: (context, snap) {
        if (snap.hasError) {
          // Bad JSON is a product state, not a crash.
          return const ListTile(
            leading: Icon(Icons.edit_note),
            title: Text("Couldn't fill this in. Please add the details."),
          );
        }
        final t = snap.data;
        if (t == null) return const LinearProgressIndicator();
        return Card(
          child: ListTile(
            title: Text(t.summary),
            subtitle: Text('${t.category.name} · ${t.platform.name}'
                '${t.steps.isEmpty ? '' : ' · ${t.steps.length} steps'}'),
            trailing: Chip(label: Text(t.priority.name)),
          ),
        );
      },
    );
  }
}
