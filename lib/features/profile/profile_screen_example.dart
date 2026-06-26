// // USAGE EXAMPLE — not part of the feature, just a reference for wiring.
// //
// // Drop this logic into your route (GoRouter builder) once you have a
// // ProfileCubit emitting ProfileState{ user, connectionStatus, isMe }.

// import 'package:flutter/material.dart';
// import 'package:pulse_chat/features/profile/edit_profile_screen.dart';
// import 'package:pulse_chat/features/profile/profile_models.dart';
// import 'package:pulse_chat/features/profile/profile_screen.dart';

// class ProfileScreenExample extends StatefulWidget {
//   const ProfileScreenExample({required this.isMe, super.key});
//   final bool isMe;

//   @override
//   State<ProfileScreenExample> createState() => _ProfileScreenExampleState();
// }

// class _ProfileScreenExampleState extends State<ProfileScreenExample> {
//   // TODO(bloc): replace this local state with ProfileCubit's emitted state.
//   late ProfileUserEntity _user = const ProfileUserEntity(
//     id: 'u_001',
//     name: 'Ananya Sharma',
//     username: 'ananya.codes',
//     email: 'ananya@example.com',
//     mobile: '+91 98765 43210',
//     bio: 'Flutter dev. Building Pulse Chat. Coffee-powered.',
//     onlineStatus: OnlineStatus.online,
//     socialLinks: [
//       SocialLink(platform: SocialPlatform.instagram, url: 'https://instagram.com/ananya'),
//       SocialLink(platform: SocialPlatform.linkedin, url: 'https://linkedin.com/in/ananya'),
//     ],
//     customUrl: 'https://ananya.dev',
//   );

//   ConnectionStatus _connectionStatus = ConnectionStatus.none;

//   @override
//   Widget build(BuildContext context) {
//     return ProfileScreen(
//       user: _user,
//       isMe: widget.isMe,
//       connectionStatus: _connectionStatus,
//       onEditProfile: () async {
//         await Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => EditProfileScreen(
//               user: _user,
//               onSave: (updated) {
//                 // TODO(bloc): context.read<ProfileCubit>().updateProfile(updated);
//                 setState(() => _user = updated);
//                 Navigator.of(context).pop();
//               },
//               onChangePhoto: () {
//                 // TODO: hook up image_picker, then call
//                 // context.read<ProfileCubit>().updatePhoto(file);
//               },
//             ),
//           ),
//         );
//       },
//       onToggleOnlineStatus: (status) {
//         // TODO(bloc): context.read<ProfileCubit>().setOnlineStatus(status);
//         setState(() => _user = _user.copyWith(onlineStatus: status));
//       },
//       onSendRequest: () {
//         // TODO(bloc): context.read<ConnectionCubit>().sendRequest(_user.id);
//         setState(() => _connectionStatus = ConnectionStatus.requestSent);
//       },
//       onMessage: () {
//         // TODO: GoRouter push to chat screen with _user.id
//       },
//       onBlock: () {
//         // TODO(bloc): context.read<ConnectionCubit>().blockUser(_user.id);
//       },
//       onReport: () {
//         // TODO: open report-reason bottom sheet, then dispatch to cubit
//       },
//       onOpenLink: (url) {
//         // TODO: url_launcher -> launchUrl(Uri.parse(url))
//       },
//     );
//   }
// }
