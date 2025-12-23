import 'package:slackalog/manipulation_page.dart';

import './measure_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final samples = [
      Sample(
        'Measure',
        'Measures distances',
        Icons.linear_scale,
        () => Navigator.of(context)
            .push<void>(MaterialPageRoute(builder: (c) => MeasurePage())),
      ),
      Sample(
        'manipulation',
        'manipulates objects',
        Icons.linear_scale,
        () => Navigator.of(context)
            .push<void>(MaterialPageRoute(builder: (c) => ManipulationPage())),
      ),
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARKit Demo'),
      ),
      body:
          ListView(children: samples.map((s) => SampleItem(item: s)).toList()),
    );
  }
}

class SampleItem extends StatelessWidget {
  const SampleItem({
    required this.item,
    super.key,
  });
  final Sample item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => item.onTap(),
        child: ListTile(
          leading: Icon(item.icon),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            item.description,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}

class Sample {
  const Sample(this.title, this.description, this.icon, this.onTap);
  final String title;
  final String description;
  final IconData icon;
  final Function onTap;
}