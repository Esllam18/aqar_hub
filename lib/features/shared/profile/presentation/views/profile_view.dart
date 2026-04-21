import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/profile_error_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/profile_loading_veiw.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqar_hub/main.dart' show routeObserver;
import '../cubit/profile_cubit.dart';

class ProfileView extends StatefulWidget {
  final AppRole role;
  final String uid;

  const ProfileView({super.key, required this.role, required this.uid});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      final route = ModalRoute.of(context);
      if (route != null) routeObserver.subscribe(this, route);
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _loadProfile(forceRefresh: true);

  void _loadProfile({bool forceRefresh = false}) {
    if (!mounted) return;
    context.read<ProfileCubit>().loadProfile(
      widget.uid,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          CustomSnackBar.show(
            context,
            message: state.messageKey.tr(context),
            type: SnackBarType.error,
          );
        }
        if (state is ProfileUpdated) {
          _loadProfile(forceRefresh: true);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const LoadingView();
          }
          if (state is ProfileError) {
            return ErrorView(
              messageKey: state.messageKey,
              onRetry: () => _loadProfile(forceRefresh: true),
            );
          }
          final profile = switch (state) {
            ProfileLoaded(:final profile) => profile,
            ProfileUpdating(:final profile) => profile,
            ProfileUpdated(:final profile) => profile,
            _ => null,
          };
          if (profile == null) return const SizedBox.shrink();
          return ProfileBody(
            profile: profile,
            role: widget.role,
            uid: widget.uid,
          );
        },
      ),
    );
  }
}
