import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/database/tables/qbittorrent.dart';
import 'package:lunasea/extensions/string/links.dart';
import 'package:lunasea/modules/qbittorrent.dart';
import 'package:lunasea/router/routes/qbittorrent.dart';

import 'package:lunasea/system/filesystem/file.dart';
import 'package:lunasea/system/filesystem/filesystem.dart';

class QBittorrentRoute extends StatefulWidget {
  final bool showDrawer;

  const QBittorrentRoute({
    Key? key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<QBittorrentRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  LunaPageController? _pageController;
  String _profileState = LunaProfile.current.toString();
  NZBGetAPI _api = NZBGetAPI.from(LunaProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        LunaPageController(initialPage: QBittorrentDatabase.NAVIGATION_INDEX.read());
  }

  @override
  Widget build(BuildContext context) {
    return LunaScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      drawer: widget.showDrawer ? _drawer() : null,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      extendBodyBehindAppBar: false,
      extendBody: false,
      onProfileChange: (_) {
        if (_profileState != LunaProfile.current.toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => LunaDrawer(page: LunaModule.QBITTORRENT.key);

  Widget? _bottomNavigationBar() {
    if (LunaProfile.current.qbittorrentEnabled) {
      return QBittorrentNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = LunaBox.profiles.keys.fold([], (value, element) {
      if (LunaBox.profiles.read(element)?.qbittorrentEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (LunaProfile.current.qbittorrentEnabled)
      actions = [
        Selector<QBittorentState, bool>(
          selector: (_, model) => model.error,
          builder: (context, error, widget) =>
              error ? Container() : const QBittorrentAppBarStats(),
        ),
        LunaIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return LunaAppBar.dropdown(
      title: LunaModule.QBITTORRENT.title,
      useDrawer: widget.showDrawer,
      hideLeading: !widget.showDrawer,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: QBittorrentNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    if (!LunaProfile.current.qbittorrentEnabled)
      return LunaMessage.moduleNotEnabled(
        context: context,
        module: LunaModule.QBITTORRENT.title,
      );
    return LunaPageView(
      controller: _pageController,
      children: [
        NZBGetQueue(
          refreshIndicatorKey: _refreshKeys[0],
        ),
        NZBGetHistory(
          refreshIndicatorKey: _refreshKeys[1],
        ),
      ],
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await QBittorrentDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          LunaProfile profile = LunaProfile.current;
          await profile.qbittorrentHost.openLink();
          break;
        case 'add_nzb':
          _addNZB();
          break;
        case 'sort':
          _sort();
          break;
        case 'server_details':
          _serverDetails();
          break;
        default:
          LunaLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addNZB() async {
    List values = await QBittorrentDialogs.addNZB(context);
    if (values[0])
      switch (values[1]) {
        case 'link':
          _addByURL();
          break;
        case 'file':
          _addByFile();
          break;
        default:
          LunaLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addByURL() async {
    List values = await QBittorrentDialogs.addNZBUrl(context);
    if (values[0])
      await _api
          .uploadURL(values[1])
          .then((_) => showLunaSuccessSnackBar(
              title: 'Uploaded NZB (URL)', message: values[1]))
          .catchError((error) => showLunaErrorSnackBar(
              title: 'Failed to Upload NZB', error: error));
  }

  Future<void> _addByFile() async {
    try {
      LunaFile? _file = await LunaFileSystem().read(context, [
        'nzb',
      ]);
      if (_file != null) {
        if (_file.data.isNotEmpty) {
          await _api.uploadFile(_file.data, _file.name).then((value) {
            _refreshKeys[0]?.currentState?.show();
            showLunaSuccessSnackBar(
              title: 'Uploaded NZB (File)',
              message: _file.name,
            );
          });
        } else {
          showLunaErrorSnackBar(
            title: 'Failed to Upload NZB',
            message: 'Please select a valid file',
          );
        }
      }
    } catch (error, stack) {
      LunaLogger().error('Failed to add NZB by file', error, stack);
      showLunaErrorSnackBar(
        title: 'Failed to Upload NZB',
        error: error,
      );
    }
  }

  Future<void> _sort() async {
    List values = await QBittorrentDialogs.sortQueue(context);
    if (values[0])
      await _api.sortQueue(values[1]).then((_) {
        _refreshKeys[0]?.currentState?.show();
        showLunaSuccessSnackBar(
            title: 'Sorted Queue', message: (values[1] as NZBGetSort?).name);
      }).catchError((error) {
        showLunaErrorSnackBar(title: 'Failed to Sort Queue', error: error);
      });
  }

  Future<void> _serverDetails() async => QBittorrentRoutes.STATISTICS.go();

  void _refreshProfile() {
    _api = NZBGetAPI.from(LunaProfile.current);
    _profileState = LunaProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
