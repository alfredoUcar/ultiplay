import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/screens/new_game.dart';
import 'package:ultiplay/states/config.dart' as States;
import 'package:ultiplay/states/current_game.dart' as States;
import 'package:ultiplay/states/played_games.dart' as States;
import 'package:ultiplay/widgets/global_menu.dart';
import 'package:ultiplay/widgets/played_games.dart';

class Home extends StatefulWidget {
  static const routeName = 'home';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd? banner;
  bool bannerAvailable = false;

  loadBanner(String id) {
    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: id,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            bannerAvailable = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
          ad.dispose();
          setState(() {
            bannerAvailable = false;
          });
        },
      ),
      request: AdRequest(),
    );

    banner!.load();
  }

  @override
  void dispose() {
    if (banner != null) {
      banner!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ultiplay'),
      ),
      drawer: GlobalMenu(),
      body: Center(
        child: getHomeContent(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Consumer<States.CurrentGame>(
        builder: (context, currentGame, child) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: !currentGame.isEmpty() && !currentGame.finished(),
              child: FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CurrentGame.routeName);
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.add),
                tooltip: 'New game',
                onPressed: () {
                  Navigator.of(context).pushNamed(NewGame.routeName);
                }),
          ],
        ),
      ),
    );
  }

  Widget getHomeContent(BuildContext context) {
    return Consumer<States.PlayedGames>(builder: (context, playedGames, child) {
      if (playedGames.fetching()) {
        return CircularProgressIndicator();
      }

      if (!playedGames.fetched()) {
        return Text('Not fetched yet');
      }

      // data is fetched
      if (playedGames.isEmpty()) {
        return Text('Press "+" button to start your first game');
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<States.Config>(
            builder: (context, config, child) {
              if (!config.loaded || !config.data.containsKey('homeAdId')) {
                return Container();
              }

              if (banner == null) {
                loadBanner(config.data['homeAdId']);
                return Container();
              }

              if (!bannerAvailable) {
                return Container();
              }

              return Container(
                alignment: Alignment.center,
                height: (banner!.size.height + 20).toDouble(),
                width: banner!.size.width.toDouble(),
                child: AdWidget(key: Key('banner'), ad: banner as BannerAd),
              );
            },
          ),
          PlayedGames(),
        ],
      );
    });
  }
}
