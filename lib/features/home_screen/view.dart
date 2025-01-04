// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/account_context/state.dart';
import '../recent_drawing/recent_drawing_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _loadRecentDrawings(BuildContext context) {
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
    _loadRecentDrawings(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocBuilder<AccountContextBloc, AccountContextState>(
          builder: (context, state) {
            return Text(
              "Welcome, ${FirebaseAuth.instance.currentUser?.displayName ?? ""}",
              style: Theme.of(context).textTheme.titleLarge,
            );
          },
        ),
        Text(
          "Here's what's happening on your projects today.",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.sticky_note_2),
            title: const Text('Add Sheets'),
            onTap: () => context.push('/drawing-publish/file-upload'),
          ),
        ),
        const RecentDrawingView(),
      ],
    );
  }
}
