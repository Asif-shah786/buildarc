import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart';
import 'package:ardennes/libraries/core_ui/image_downloading/image_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../libraries/account_context/bloc.dart';
import '../../libraries/account_context/state.dart';

class RecentDrawingView extends StatelessWidget {
  const RecentDrawingView({super.key});

  void loadRecentDrawings(BuildContext context) {
    final state = context.watch<AccountContextBloc>().state;
    if (state is AccountContextLoadedState && state.selectedProject != null) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<RecentDrawingBloc>().add(
              LoadRecentDrawings(
                projectId: state.selectedProject!.id!,
                userId: uid,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        children: [
          ListTile(
            leading: Text("Recently viewed sheets", style: Theme.of(context).textTheme.titleLarge),
            trailing: TextButton(
              onPressed: () {},
              child: Text("See all", style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 0),
          ),
          SizedBox(
            height: 240,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<RecentDrawingBloc, RecentDrawingState>(
                builder: (context, state) {
                  if (state is RecentDrawingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RecentDrawingLoaded) {
                    final drawings = state.log?.drawings ?? [];
                    if (drawings.isEmpty) {
                      return const Center(child: Text("No recently viewed sheets"));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: drawings.length,
                      itemBuilder: (BuildContext context, int index) => _RecentlyViewedDrawingTile(
                          title: drawings[index].title,
                          subtitle: drawings[index].subTitle,
                          drawingThumbnailUrl: drawings[index].url),
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 16.0),
                    );
                  } else if (state is RecentDrawingError) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        ElevatedButton(
                            onPressed: () {
                              loadRecentDrawings(context);
                            },
                            child: Text('Try again')),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyViewedDrawingTile extends StatelessWidget {
  const _RecentlyViewedDrawingTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.drawingThumbnailUrl,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String drawingThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          context.go(
            Uri(
              path: '/drawings/sheet',
              queryParameters: {
                'number': title,
                'collection': subtitle,
                'versionId': "0",
              },
            ).toString(),
          );
        },
        child: Container(
          width: 135,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(children: [
                Expanded(
                  flex: 4,
                  // child: Image.asset(drawingThumbnailUrl),
                  child: ImageFromFirebase(imageUrl: drawingThumbnailUrl),
                ),
                const Divider(),
                Expanded(
                    flex: 2,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ])),
              ])),
        ));
  }
}
