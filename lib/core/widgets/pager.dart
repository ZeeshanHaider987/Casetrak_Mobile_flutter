import 'package:flutter/material.dart';

class Pager extends StatelessWidget {
  const Pager({
    super.key,
    required this.page,
    required this.pageCount,
    required this.totalCount,
    required this.onPage,
  });

  final int page;
  final int pageCount;
  final int totalCount;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous page',
            onPressed: page > 1 ? () => onPage(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              'Page $page of $pageCount · $totalCount',
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: page < pageCount ? () => onPage(page + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
