class Paged<T> {
  const Paged({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  int get pageCount => totalCount == 0 ? 1 : ((totalCount + pageSize - 1) ~/ pageSize);
}
