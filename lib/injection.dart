import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/drawing/drawing_catalog_loader.dart';
import 'package:ardennes/libraries/drawing/recent_drawing_service.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'features/recent_drawing/recent_drawing_bloc.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

abstract class Env {
  static const dev = 'dev';
  static const prod = 'prod';
}

@module
abstract class RegisterModule {
  @factoryMethod
  DrawingsCatalogBloc get drawingsCatalogBloc => DrawingsCatalogBloc(getIt<DrawingCatalogService>());

  @factoryMethod
  AccountContextBloc get accountContextBloc => AccountContextBloc();

  @factoryMethod
  RecentDrawingBloc get recentDrawingBloc => RecentDrawingBloc(getIt<RecentDrawingService>());
}
