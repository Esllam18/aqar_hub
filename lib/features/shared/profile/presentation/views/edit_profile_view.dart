import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/edit_profile/image_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/edit_profile/edit_profile_avatar_widget.dart';
import '../widgets/edit_profile/edit_profile_personal_section.dart';
import '../widgets/edit_profile/edit_profile_optional_section.dart';

class EditProfileView extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _nationalIdCtrl;
  late final TextEditingController _addressCtrl;
  DateTime? _dateOfBirth;
  File? _pickedImage;
  bool _isUploadingImage = false;
  bool _imageRemoved = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _cityError;
  static const _kAvatarBucket = 'avatars';

  String? get _resolvedAvatarUrl {
    if (widget.profile.profileImageUrl != null &&
        widget.profile.profileImageUrl!.isNotEmpty) {
      return widget.profile.profileImageUrl;
    }
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['avatar_url'] as String? ?? meta?['picture'] as String?;
  }

  bool get _hasAnyAvatar => _pickedImage != null || _resolvedAvatarUrl != null;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _firstNameCtrl = TextEditingController(text: p.firstName);
    _lastNameCtrl = TextEditingController(text: p.lastName);
    _phoneCtrl = TextEditingController(text: p.phoneNumber);
    _cityCtrl = TextEditingController(text: p.city);
    _nationalIdCtrl = TextEditingController(text: p.nationalId);
    _addressCtrl = TextEditingController(text: p.address);
    _dateOfBirth = p.dateOfBirth != null
        ? DateTime.tryParse(p.dateOfBirth!)
        : null;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _firstNameError = _firstNameCtrl.text.trim().isEmpty
          ? 'val_first_name_required'
          : null;
      _lastNameError = _lastNameCtrl.text.trim().isEmpty
          ? 'val_last_name_required'
          : null;
      _phoneError = _validatePhone(_phoneCtrl.text.trim());
      _cityError = _cityCtrl.text.trim().isEmpty ? 'val_city_required' : null;
    });
    return [
      _firstNameError,
      _lastNameError,
      _phoneError,
      _cityError,
    ].every((e) => e == null);
  }

  String? _validatePhone(String v) {
    if (v.isEmpty) return 'val_phone_required';
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(v)) return 'val_phone_invalid';
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _imageRemoved = false;
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ImageOptionsSheet(
        onCamera: () => _pickImage(ImageSource.camera),
        onGallery: () => _pickImage(ImageSource.gallery),
        onRemove: _hasAnyAvatar
            ? () {
                Navigator.of(context).pop();
                setState(() {
                  _pickedImage = null;
                  _imageRemoved = true;
                });
              }
            : null,
      ),
    );
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final path = 'profiles/$uid/avatar.jpg';
      final bytes = await file.readAsBytes();

      await Supabase.instance.client.storage
          .from(_kAvatarBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final base = Supabase.instance.client.storage
          .from(_kAvatarBucket)
          .getPublicUrl(path);

      imageCache.evict(NetworkImage(base));
      imageCache.evict(NetworkImage(widget.profile.profileImageUrl ?? ''));

      final versioned = '$base?v=${DateTime.now().millisecondsSinceEpoch}';
      return versioned;
    } on StorageException catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: e.message,
          type: SnackBarType.error,
        );
      }
      return null;
    }
  }

  Future<void> _save() async {
    if (!_validate()) return;

    String? imageUrl;
    if (_pickedImage != null) {
      setState(() => _isUploadingImage = true);
      imageUrl = await _uploadImage(_pickedImage!);
      setState(() => _isUploadingImage = false);
      if (imageUrl == null) return;
    } else if (_imageRemoved) {
      imageUrl = null;
    } else {
      imageUrl = widget.profile.profileImageUrl;
    }

    if (!mounted) return;

    context.read<ProfileCubit>().updateProfile(
      widget.profile.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        nationalId: _nationalIdCtrl.text.trim().isEmpty
            ? null
            : _nationalIdCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        profileImageUrl: imageUrl,
        dateOfBirth: _dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
            : null,
      ),
    );
  }

  void _handleState(BuildContext context, ProfileState state) {
    if (state is ProfileUpdated) {
      CustomSnackBar.show(
        context,
        message: 'profile_update_success'.tr(context),
        type: SnackBarType.success,
      );
      Navigation.back();
    }
    if (state is ProfileError) {
      CustomSnackBar.show(
        context,
        message: state.messageKey.tr(context),
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: _handleState,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileUpdating || _isUploadingImage;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.primary,
                  pinned: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: context.r(24),
                    ),
                    onPressed: Navigation.back,
                  ),
                  title: Text(
                    'profile_menu_edit'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    if (!isLoading)
                      TextButton(
                        onPressed: _save,
                        child: Text(
                          'btn_save'.tr(context),
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(15),
                          ),
                        ),
                      ),
                    SizedBox(width: context.r(4)),
                  ],
                ),

                SliverToBoxAdapter(
                  child: EditProfileAvatarWidget(
                    profile: widget.profile,
                    resolvedAvatarUrl: _imageRemoved
                        ? null
                        : _resolvedAvatarUrl,
                    pickedImage: _pickedImage,
                    isUploading: _isUploadingImage,
                    onTap: _showImageOptions,
                  ),
                ),

                SliverPadding(
                  padding: context.rAll(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      EditProfilePersonalSection(
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        phoneCtrl: _phoneCtrl,
                        cityCtrl: _cityCtrl,
                        firstNameError: _firstNameError?.tr(context),
                        lastNameError: _lastNameError?.tr(context),
                        phoneError: _phoneError?.tr(context),
                        cityError: _cityError?.tr(context),
                      ),
                      SizedBox(height: context.r(20)),
                      EditProfileOptionalSection(
                        nationalIdCtrl: _nationalIdCtrl,
                        addressCtrl: _addressCtrl,
                        dateOfBirth: _dateOfBirth,
                        onDatePicked: (d) => setState(() => _dateOfBirth = d),
                      ),
                      SizedBox(height: context.r(28)),
                      LoadingButton(
                        isLoading: isLoading,
                        textKey: 'btn_save',
                        loadingTextKey: 'loading_saving',
                        icon: Icons.check_circle_outline,
                        onPressed: _save,
                      ),
                      SizedBox(height: context.r(40)),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
