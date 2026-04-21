import 'package:flutter/material.dart';

class CatalogItem {
  final String value;
  final String en;
  final String ar;

  const CatalogItem({required this.value, required this.en, required this.ar});

  String label(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? ar : en;
  }
}

abstract final class PropertyCatalog {
  static const governorates = [
    CatalogItem(value: 'cairo', en: 'Cairo', ar: 'القاهرة'),
    CatalogItem(value: 'giza', en: 'Giza', ar: 'الجيزة'),
    CatalogItem(value: 'alexandria', en: 'Alexandria', ar: 'الإسكندرية'),
    CatalogItem(value: 'dakahlia', en: 'Dakahlia', ar: 'الدقهلية'),
    CatalogItem(value: 'sharkia', en: 'Sharqia', ar: 'الشرقية'),
    CatalogItem(value: 'qalyubia', en: 'Qalyubia', ar: 'القليوبية'),
    CatalogItem(value: 'beheira', en: 'Beheira', ar: 'البحيرة'),
    CatalogItem(value: 'gharbia', en: 'Gharbia', ar: 'الغربية'),
    CatalogItem(value: 'kafr_el_sheikh', en: 'Kafr El Sheikh', ar: 'كفر الشيخ'),
    CatalogItem(value: 'monufia', en: 'Monufia', ar: 'المنوفية'),
    CatalogItem(value: 'damietta', en: 'Damietta', ar: 'دمياط'),
    CatalogItem(value: 'port_said', en: 'Port Said', ar: 'بورسعيد'),
    CatalogItem(value: 'ismailia', en: 'Ismailia', ar: 'الإسماعيلية'),
    CatalogItem(value: 'suez', en: 'Suez', ar: 'السويس'),
    CatalogItem(value: 'fayoum', en: 'Fayoum', ar: 'الفيوم'),
    CatalogItem(value: 'beni_suef', en: 'Beni Suef', ar: 'بني سويف'),
    CatalogItem(value: 'minya', en: 'Minya', ar: 'المنيا'),
    CatalogItem(value: 'asyut', en: 'Asyut', ar: 'أسيوط'),
    CatalogItem(value: 'sohag', en: 'Sohag', ar: 'سوهاج'),
    CatalogItem(value: 'qena', en: 'Qena', ar: 'قنا'),
    CatalogItem(value: 'luxor', en: 'Luxor', ar: 'الأقصر'),
    CatalogItem(value: 'aswan', en: 'Aswan', ar: 'أسوان'),
    CatalogItem(value: 'red_sea', en: 'Red Sea', ar: 'البحر الأحمر'),
    CatalogItem(value: 'matrouh', en: 'Matrouh', ar: 'مطروح'),
    CatalogItem(value: 'new_valley', en: 'New Valley', ar: 'الوادي الجديد'),
    CatalogItem(value: 'north_sinai', en: 'North Sinai', ar: 'شمال سيناء'),
    CatalogItem(value: 'south_sinai', en: 'South Sinai', ar: 'جنوب سيناء'),
  ];

  static const propertyTypes = [
    CatalogItem(value: 'apartment', en: 'Apartment', ar: 'شقة'),
    CatalogItem(value: 'villa', en: 'Villa', ar: 'فيلا'),
    CatalogItem(value: 'studio', en: 'Studio', ar: 'استوديو'),
    CatalogItem(value: 'penthouse', en: 'Penthouse', ar: 'بنتهاوس'),
    CatalogItem(value: 'duplex', en: 'Duplex', ar: 'دوبلكس'),
    CatalogItem(value: 'chalet', en: 'Chalet', ar: 'شاليه'),
  ];

  static const amenities = [
    CatalogItem(value: 'wifi', en: 'Wi-Fi', ar: 'واي فاي'),
    CatalogItem(value: 'air_conditioning', en: 'Air Conditioning', ar: 'تكييف'),
    CatalogItem(value: 'elevator', en: 'Elevator', ar: 'مصعد'),
    CatalogItem(value: 'parking', en: 'Parking', ar: 'موقف سيارات'),
    CatalogItem(value: 'security', en: 'Security', ar: 'أمن'),
    CatalogItem(value: 'balcony', en: 'Balcony', ar: 'بلكونة'),
    CatalogItem(value: 'kitchen', en: 'Kitchen', ar: 'مطبخ'),
    CatalogItem(value: 'laundry', en: 'Laundry', ar: 'غسالة'),
    CatalogItem(
      value: 'private_bathroom',
      en: 'Private Bathroom',
      ar: 'حمام خاص',
    ),
    CatalogItem(
      value: 'shared_bathroom',
      en: 'Shared Bathroom',
      ar: 'حمام مشترك',
    ),
    CatalogItem(value: 'natural_gas', en: 'Natural Gas', ar: 'غاز طبيعي'),
    CatalogItem(value: 'water_meter', en: 'Water Meter', ar: 'عداد مياه'),
    CatalogItem(
      value: 'electric_meter',
      en: 'Electric Meter',
      ar: 'عداد كهرباء',
    ),
    CatalogItem(value: 'garden', en: 'Garden', ar: 'حديقة'),
    CatalogItem(value: 'pool', en: 'Pool', ar: 'حمام سباحة'),
    CatalogItem(value: 'gym', en: 'Gym', ar: 'جيم'),
    CatalogItem(
      value: 'pets_allowed',
      en: 'Pets Allowed',
      ar: 'مسموح بالحيوانات',
    ),
    CatalogItem(
      value: 'near_transport',
      en: 'Near Transport',
      ar: 'قريب من المواصلات',
    ),
    CatalogItem(value: 'sea_view', en: 'Sea View', ar: 'إطلالة بحر'),
    CatalogItem(value: 'roof', en: 'Roof', ar: 'روف'),
  ];
}
