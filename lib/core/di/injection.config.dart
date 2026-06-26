// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pulse_chat/core/database/cubit/settings_cubit.dart' as _i674;
import 'package:pulse_chat/core/database/prefs_store.dart' as _i208;
import 'package:pulse_chat/core/network/network_module.dart' as _i968;
import 'package:pulse_chat/features/authentication/bloc/auth_bloc.dart'
    as _i290;
import 'package:pulse_chat/features/authentication/data/auth_repository.dart'
    as _i1;
import 'package:pulse_chat/features/contacts/bloc/contacts_bloc.dart' as _i979;
import 'package:pulse_chat/features/contacts/bloc/search_users_bloc.dart'
    as _i182;
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart'
    as _i207;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.singleton<_i208.PrefsStore>(() => _i208.PrefsStore());
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i1.AuthRepository>(() => _i1.AuthRepository());
    gh.factory<_i674.SettingsCubit>(
      () => _i674.SettingsCubit(gh<_i208.PrefsStore>()),
    );
    gh.lazySingleton<_i207.ContactsRepository>(
      () => _i207.ContactsRepository(gh<_i361.Dio>()),
    );
    gh.factory<_i290.AuthBloc>(() => _i290.AuthBloc(gh<_i1.AuthRepository>()));
    gh.factory<_i979.ContactsBloc>(
      () => _i979.ContactsBloc(gh<_i207.ContactsRepository>()),
    );
    gh.factory<_i182.SearchUsersBloc>(
      () => _i182.SearchUsersBloc(gh<_i207.ContactsRepository>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i968.NetworkModule {}
