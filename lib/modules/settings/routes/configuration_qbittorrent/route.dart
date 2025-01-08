import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/qbittorrent.dart';
import 'package:lunasea/router/routes/settings.dart';

class ConfigurationQBittorrentRoute extends StatefulWidget {
  const ConfigurationQBittorrentRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationQBittorrentRoute> createState() => _State();
}

class _State extends State<ConfigurationQBittorrentRoute>
    with LunaScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LunaScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return LunaAppBar(
      title: LunaModule.QBITTORRENT.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return LunaListView(
      controller: scrollController,
      children: [
        LunaModule.QBITTORRENT.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        LunaDivider(),
        _defaultPagesPage(),
        //_defaultPagesPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return LunaBox.profiles.listenableBuilder(
      builder: (context, _) => LunaBlock(
        title: 'settings.EnableModule'.tr(args: [LunaModule.QBITTORRENT.title]),
        trailing: LunaSwitch(
          value: LunaProfile.current.nzbgetEnabled,
          onChanged: (value) {
            LunaProfile.current.nzbgetEnabled = value;
            LunaProfile.current.save();
            context.read<QBittorentState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return LunaBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'
              .tr(args: [LunaModule.QBITTORRENT.title]),
        ),
      ],
      trailing: const LunaIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_QBITTORRENT_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return LunaBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const LunaIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_QBITTORRENT_DEFAULT_PAGES.go,
    );
  }
}
