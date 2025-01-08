import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/database/tables/qbittorrent.dart';
import 'package:lunasea/modules/qbittorrent.dart';

class ConfigurationQBittorrentDefaultPagesRoute extends StatefulWidget {
  const ConfigurationQBittorrentDefaultPagesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationQBittorrentDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationQBittorrentDefaultPagesRoute>
    with LunaScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LunaScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return LunaAppBar(
      title: 'settings.DefaultPages'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return LunaListView(
      controller: scrollController,
      children: [
        _homePage(),
      ],
    );
  }

  Widget _homePage() {
    const _db = QBittorrentDatabase.NAVIGATION_INDEX;
    return _db.listenableBuilder(
      builder: (context, _) => LunaBlock(
        title: 'lunasea.Home'.tr(),
        body: [TextSpan(text: QBittorrentNavigationBar.titles[_db.read()])],
        trailing: LunaIconButton(
          icon: QBittorrentNavigationBar.icons[_db.read()],
        ),
        onTap: () async {
          List values = await QBittorrentDialogs.defaultPage(context);
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }
}
