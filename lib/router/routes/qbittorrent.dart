import 'package:flutter/material.dart';
import 'package:lunasea/modules.dart';
import 'package:lunasea/modules/qbittorrent/routes/qbittorrent.dart';
import 'package:lunasea/modules/qbittorrent/routes/statistics.dart';
import 'package:lunasea/router/routes.dart';
import 'package:lunasea/vendor.dart';

enum QBittorrentRoutes with LunaRoutesMixin {
  HOME('/qbittorrent'),
  STATISTICS('statistics');

  @override
  final String path;

  const QBittorrentRoutes(this.path);

  @override
  LunaModule get module => LunaModule.QBITTORRENT;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case QBittorrentRoutes.HOME:
        return route(widget: const QBittorrentRoute());
      case QBittorrentRoutes.STATISTICS:
        return route(widget: const StatisticsRoute());
    }
  }

  @override
  List<GoRoute> get subroutes {
    switch (this) {
      case QBittorrentRoutes.HOME:
        return [
          QBittorrentRoutes.STATISTICS.routes,
        ];
      default:
        return const [];
    }
  }
}
