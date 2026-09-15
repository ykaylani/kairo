import 'package:flutter/material.dart';

import 'templ/btntemp.dart';
import 'templ/colors.dart';

import 'templ/cardsys/cardsysstruct.dart';
import 'templ/cardsys/cardsyslk.dart';

void main() { runApp(const Kairo()); }

class Kairo extends StatelessWidget {
  const Kairo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Kairo',
      home: Homepage(title: 'Kairo - Dashboard'),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.title});
  final String title;

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: ColorsMain.primary,
        title: Text(widget.title),
        actionsPadding: const EdgeInsets.only(right: 16.0),

        actions: <Widget>[

          TemplateButtonTI(
            label: "Settings",
            icon: Icons.settings,
            func: () {},
            backColor: ColorsMain.btn,
            ictColor: ColorsMain.textOnBtn,
          )

        ]
      ),

      body: Center(
        child: Container (
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ColorsMain.gradStart, ColorsMain.gradEnd]
              )
          ),

          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16.0, bottom: 80.0),
            itemCount: placeholderDevices.length,
            itemBuilder: (context, index) { return DeviceCard(device: placeholderDevices[index]); },
          ),

        )
      ),

      floatingActionButton: TemplateButtonIcon(
        icon: Icons.add,
        iconSize: 36,
        func: () {},
        backColor: ColorsMain.btn,
        ictColor: ColorsMain.textOnBtn,
      ),

    );
  }
}