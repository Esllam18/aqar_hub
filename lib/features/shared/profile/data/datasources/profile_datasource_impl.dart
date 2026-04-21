import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'profile_datasource.dart';

class ProfileDatasourceImpl implements ProfileDatasource {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<ProfileModel> getProfile(String uid) async {
    final data = await _db.from('profiles').select().eq('id', uid).single();
    return ProfileModel.fromMap(data);
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel model) async {
    await _db.from('profiles').upsert(model.toMap());
    // Re-fetch to get server-computed fields (favorites_count etc.)
    return getProfile(model.uid);
  }
}
