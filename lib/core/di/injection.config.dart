// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pulse_chat/core/database/cubit/settings_cubit.dart' as _i674;
import 'package:pulse_chat/core/database/prefs_store.dart' as _i208;
import 'package:pulse_chat/features/authentication/data/auth_repository.dart'
    as _i499;
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart'
    as _i290;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i208.PrefsStore>(() => _i208.PrefsStore());
    gh.lazySingleton<_i499.AuthRepository>(() => _i499.AuthRepository());
    gh.factory<_i674.SettingsCubit>(
      () => _i674.SettingsCubit(gh<_i208.PrefsStore>()),
    );
    gh.factory<_i290.AuthBloc>(
      () => _i290.AuthBloc(gh<_i499.AuthRepository>()),
    );
    return this;
  }
}
