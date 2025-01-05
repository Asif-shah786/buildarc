// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ardennes/features/drawing_detail/drawing_detail_bloc.dart'
    as _i905;
import 'package:ardennes/features/drawings_catalog/drawings_catalog_bloc.dart'
    as _i608;
import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart'
    as _i984;
import 'package:ardennes/injection.dart' as _i252;
import 'package:ardennes/libraries/account_context/bloc.dart' as _i934;
import 'package:ardennes/libraries/drawing/drawing_catalog_loader.dart'
    as _i573;
import 'package:ardennes/libraries/drawing/image_provider.dart' as _i836;
import 'package:ardennes/libraries/drawing/recent_drawing_service.dart'
    as _i1048;
import 'package:ardennes/models/projects/project_metadata.dart' as _i455;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.factory<_i836.UIImageProvider>(() => _i836.UIImageProvider());
    gh.factory<_i608.DrawingsCatalogBloc>(
        () => registerModule.drawingsCatalogBloc);
    gh.factory<_i934.AccountContextBloc>(
        () => registerModule.accountContextBloc);
    gh.factory<_i984.RecentDrawingBloc>(() => registerModule.recentDrawingBloc);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => registerModule.firebaseFirestore);
    gh.factory<_i1048.RecentDrawingService>(() =>
        _i1048.RecentDrawingService(firestore: gh<_i974.FirebaseFirestore>()));
    gh.factoryParam<_i573.DrawingCatalogService, _i455.ProjectMetadata?,
        dynamic>((
      savedSelectedProject,
      _,
    ) =>
        _i573.DrawingCatalogService(
            savedSelectedProject: savedSelectedProject));
    gh.factory<_i905.DrawingDetailBloc>(() =>
        _i905.DrawingDetailBloc(uiImageProvider: gh<_i836.UIImageProvider>()));
    return this;
  }
}

class _$RegisterModule extends _i252.RegisterModule {}
