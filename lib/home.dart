// ignore_for_file: prefer_final_fields, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.')),
  );

  TextEditingController _ctn = TextEditingController();
  TextEditingController _ctnupdate = TextEditingController();

  Box? ContactsDataBox;

  @override
  void initState() {
    myBanner.load();
    ContactsDataBox = Hive.box("contacts");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CURD with Hive"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextField(
                  controller: _ctn,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        final _storeNum = _ctn.text;
                        await ContactsDataBox?.add(_storeNum);
                        _ctn.clear();
                      },
                      child: const Text("save")),
                ),
                Expanded(
                  flex: 6,
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box("contacts").listenable(),
                    builder: (context, box, widget) {
                      return ListView.builder(
                          itemCount: ContactsDataBox!.keys.toList().length,
                          itemBuilder: (_, i) {
                            return Card(
                              child: ListTile(
                                dense: true,
                                title:
                                    Text(ContactsDataBox!.getAt(i).toString()),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        "Edit current number"),
                                                    content: Column(
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              _ctnupdate,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                await ContactsDataBox!
                                                                    .putAt(
                                                                        i,
                                                                        _ctnupdate
                                                                            .text);
                                                                _ctnupdate
                                                                    .clear();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  "Update")),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          color: Colors.blue,
                                          icon: const Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () async {
                                            await ContactsDataBox!.deleteAt(i);
                                          },
                                          color: Colors.red,
                                          icon: const Icon(Icons.clear)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AdWidget(ad: myBanner),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
