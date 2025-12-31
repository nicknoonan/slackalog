import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupImage.dart';
import 'package:slackalog/slackSetupModel.dart';

class SlackSetupCard extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final VoidCallback? onTap;

  const SlackSetupCard({super.key, required this.slackSetup, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: slackSetup,
      builder: (BuildContext context, Widget? child) {
        return Center(
          child: Card(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  spacing: 5.0,
                  children: [
                    PreviewImage(slackSetup: slackSetup),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slackSetup.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text("${slackSetup.length}m"),
                          Row(
                            children: [
                              Icon(Icons.rocket),
                              Icon(Icons.rocket),
                              Icon(Icons.rocket),
                            ],
                            spacing: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String first(String s, int num) {
  if (s.length <= num) {
    return s;
  }

  var index = num - 1;
  return s.substring(0, index);
}
