import 'package:lunasea/database/table.dart';

enum QBittorrentDatabase<T> with LunaTableMixin<T> {
  NAVIGATION_INDEX<int>(0);

  @override
  LunaTable get table => LunaTable.qbittorrent;

  @override
  final T fallback;

  const QBittorrentDatabase(this.fallback);
}
