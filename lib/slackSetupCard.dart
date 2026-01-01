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
                  children: [
                    PreviewImage(slackSetup: slackSetup),
                    const SizedBox(width: 8),
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
                            children: const [
                              Icon(Icons.rocket),
                              SizedBox(width: 10),
                              Icon(Icons.rocket),
                              SizedBox(width: 10),
                              Icon(Icons.rocket),
                            ],
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
