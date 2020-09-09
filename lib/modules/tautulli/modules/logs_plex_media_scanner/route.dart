import 'package:fluro_fork/fluro_fork.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/scheduler.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/tautulli.dart';
import 'package:tautulli/tautulli.dart';

class TautulliLogsPlexMediaScannerRoute extends StatefulWidget {
    static const String ROUTE_NAME = '/tautulli/logs/plexmediascanner/:profile';

    TautulliLogsPlexMediaScannerRoute({
        Key key,
    }) : super(key: key);

    @override
    State<StatefulWidget> createState() => _State();

    static String route({ String profile }) {
        if(profile == null) return '/tautulli/logs/plexmediascanner/${LunaSeaDatabaseValue.ENABLED_PROFILE.data}';
        return '/tautulli/logs/plexmediascanner/$profile';
    }

    static void defineRoute(Router router) => router.define(
        TautulliLogsPlexMediaScannerRoute.ROUTE_NAME,
        handler: Handler(handlerFunc: (context, params) => TautulliLogsPlexMediaScannerRoute()),
        transitionType: LunaRouter.transitionType,
    );
}

class _State extends State<TautulliLogsPlexMediaScannerRoute> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

    Future<void> _refresh() async {
        TautulliLocalState _state = Provider.of<TautulliLocalState>(context, listen: false);
        _state.resetPlexMediaScannerLogs(context);
        await _state.plexMediaScannerLogs;
    }

    @override
    void initState() {
        super.initState();
        SchedulerBinding.instance.scheduleFrameCallback((_) => _refresh());
    }

    @override
    Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: _appBar,
        body: _body,
    );

    Widget get _appBar => LSAppBar(title: 'Plex Media Scanner Logs');

    Widget get _body => LSRefreshIndicator(
        onRefresh: _refresh,
        refreshKey: _refreshKey,
        child: Selector<TautulliLocalState, Future<List<TautulliPlexLog>>>(
            selector: (_, state) => state.plexMediaScannerLogs,
            builder: (context, logs, _) => FutureBuilder(
                future: logs,
                builder: (context, AsyncSnapshot<List<TautulliPlexLog>> snapshot) {
                    if(snapshot.hasError) {
                        if(snapshot.connectionState != ConnectionState.waiting) {
                            Logger.error(
                                'TautulliLogsPlexMediaScannerRoute',
                                '_body',
                                'Unable to fetch Tautulli plex media scanner logs',
                                snapshot.error,
                                StackTrace.current,
                                uploadToSentry: !(snapshot.error is DioError),
                            );
                        }
                        return LSErrorMessage(onTapHandler: () async => _refreshKey.currentState.show());
                    }
                    if(snapshot.hasData) return snapshot.data.length == 0
                        ? _noLogs()
                        : _logs(snapshot.data);
                    return LSLoader();
                },
            ),
        ),
    );

    Widget _noLogs() => LSGenericMessage(
        text: 'No Logs Found',
        showButton: true,
        buttonText: 'Refresh',
        onTapHandler: () async => _refreshKey.currentState.show(),
    );

    Widget _logs(List<TautulliPlexLog> logs) => LSListViewBuilder(
        itemCount: logs.length,
        itemBuilder: (context, index) => TautulliLogsPlexMediaScannerLogTile(log: logs[index]),
    );
}
