import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Container(
          height: 250,
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            children: [
              Image(
                image: AssetImage('assets/images/super_gene.jpg'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Gene and the super',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                    ),
                    Text(
                      'Twelve Suns Lonely',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        'Synopsis of Book that will be shown to the user upon load of this book. It should be long enough to make a elipsis or rather it should fade over the content that is below',
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(onPressed: () {}, child: Text("Continue "))
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
