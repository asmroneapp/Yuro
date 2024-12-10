import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/work_card/work_card.dart';

class WorkRow extends StatelessWidget {
  final List<Work> works;
  final void Function(Work work)? onWorkTap;
  final double spacing;

  const WorkRow({
    super.key,
    required this.works,
    this.onWorkTap,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < works.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: WorkCard(
                work: works[i],
                onTap: onWorkTap != null ? () => onWorkTap!(works[i]) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}