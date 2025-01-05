import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ardennes/models/screens/home_screen_data.dart';
import 'event.dart';
import 'state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  ProjectMetadata? _currentSelectedProject;

  HomeScreenBloc() : super(HomeScreenState().init()) {
    on<InitEvent>(_init);
    on<FetchHomeScreenContentEvent>(_fetchHomeScreenContent);
  }

  void _init(InitEvent event, Emitter<HomeScreenState> emit) async {
    emit(state.clone());
  }

  void _fetchHomeScreenContent(FetchHomeScreenContentEvent event, Emitter<HomeScreenState> emit) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    // if (_currentSelectedProject == event.selectedProject) {
    //   return;
    // }
    if (currentUser == null) {
      return emit(HomeScreenFetchErrorState("User doesn't exist"));
    }

    emit(FetchingHomeScreenContentState());
    String userId = currentUser.uid;
    Query<HomeScreenData> homeScreenQuery = FirebaseFirestore.instance
        .collection('home_screens')
        .where('user_id', isEqualTo: userId)
        .where('project_id', isEqualTo: event.selectedProject.id)
        .withConverter(
          fromFirestore: HomeScreenData.fromFirestore,
          toFirestore: HomeScreenData.toFirestore,
        );
    try {
      QuerySnapshot<HomeScreenData> querySnapshot = await homeScreenQuery.get();
      HomeScreenData? homeScreenData = querySnapshot.docs.firstOrNull?.data();
      if (homeScreenData != null) {
        emit(FetchedHomeScreenContentState(recentlyViewedDrawingTiles: homeScreenData.drawings ?? []));
      } else {
        // TODO: Handle the project doesn't have a homescreen setup
        emit(HomeScreenFetchErrorState("Project id doesn't exist"));
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(HomeScreenFetchErrorState(e.toString()));
    }
  }
}
