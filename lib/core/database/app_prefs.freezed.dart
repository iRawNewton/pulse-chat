// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_prefs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppPrefs {

 ThemeMode get themeMode; String get languageCode;
/// Create a copy of AppPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPrefsCopyWith<AppPrefs> get copyWith => _$AppPrefsCopyWithImpl<AppPrefs>(this as AppPrefs, _$identity);

  /// Serializes this AppPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPrefs&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,languageCode);

@override
String toString() {
  return 'AppPrefs(themeMode: $themeMode, languageCode: $languageCode)';
}


}

/// @nodoc
abstract mixin class $AppPrefsCopyWith<$Res>  {
  factory $AppPrefsCopyWith(AppPrefs value, $Res Function(AppPrefs) _then) = _$AppPrefsCopyWithImpl;
@useResult
$Res call({
 ThemeMode themeMode, String languageCode
});




}
/// @nodoc
class _$AppPrefsCopyWithImpl<$Res>
    implements $AppPrefsCopyWith<$Res> {
  _$AppPrefsCopyWithImpl(this._self, this._then);

  final AppPrefs _self;
  final $Res Function(AppPrefs) _then;

/// Create a copy of AppPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? languageCode = null,}) {
  return _then(AppPrefs(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppPrefs].
extension AppPrefsPatterns on AppPrefs {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppPrefs() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppPrefs value)  $default,){
final _that = this;
switch (_that) {
case _AppPrefs():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _AppPrefs() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeMode themeMode,  String languageCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppPrefs() when $default != null:
return $default(_that.themeMode,_that.languageCode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeMode themeMode,  String languageCode)  $default,) {final _that = this;
switch (_that) {
case _AppPrefs():
return $default(_that.themeMode,_that.languageCode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeMode themeMode,  String languageCode)?  $default,) {final _that = this;
switch (_that) {
case _AppPrefs() when $default != null:
return $default(_that.themeMode,_that.languageCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppPrefs implements AppPrefs {
  const _AppPrefs({this.themeMode = defaultThemeMode, this.languageCode = defaultLanguageCode});
  factory _AppPrefs.fromJson(Map<String, dynamic> json) => _$AppPrefsFromJson(json);

@override@JsonKey() final  ThemeMode themeMode;
@override@JsonKey() final  String languageCode;

/// Create a copy of AppPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppPrefsCopyWith<_AppPrefs> get copyWith => __$AppPrefsCopyWithImpl<_AppPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppPrefs&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,languageCode);

@override
String toString() {
  return 'AppPrefs(themeMode: $themeMode, languageCode: $languageCode)';
}


}

/// @nodoc
abstract mixin class _$AppPrefsCopyWith<$Res> implements $AppPrefsCopyWith<$Res> {
  factory _$AppPrefsCopyWith(_AppPrefs value, $Res Function(_AppPrefs) _then) = __$AppPrefsCopyWithImpl;
@override @useResult
$Res call({
 ThemeMode themeMode, String languageCode
});




}
/// @nodoc
class __$AppPrefsCopyWithImpl<$Res>
    implements _$AppPrefsCopyWith<$Res> {
  __$AppPrefsCopyWithImpl(this._self, this._then);

  final _AppPrefs _self;
  final $Res Function(_AppPrefs) _then;

/// Create a copy of AppPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? languageCode = null,}) {
  return _then(_AppPrefs(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
