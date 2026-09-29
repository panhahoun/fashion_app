import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String localizedContent({
  required String khmer,
  required String english,
}) {
  final isKhmer = Get.isRegistered<LocaleController>()
      ? Get.find<LocaleController>().isKhmer
      : Get.locale?.languageCode != 'en';
  final preferred = isKhmer ? khmer : english;
  return preferred.isNotEmpty ? preferred : (isKhmer ? english : khmer);
}

String localizedCategory(String category) {
  switch (category.trim()) {
    case 'ម៉ូតស្ត្រី':
      return 'category_women'.tr;
    case 'ម៉ូតប្រុស':
      return 'category_men'.tr;
    case 'កាបូប':
      return 'category_bags'.tr;
    case 'ស្បែកជើង':
      return 'category_shoes'.tr;
    case 'គ្រឿងអលង្ការ':
      return 'category_accessories'.tr;
    default:
      return category;
  }
}

String localizedColor(String color) {
  switch (color.trim()) {
    case 'Default':
      return 'color_default'.tr;
    case 'ស':
      return 'color_white'.tr;
    case 'ខ្មៅ':
      return 'color_black'.tr;
    case 'ត្នោត':
      return 'color_brown'.tr;
    case 'ខៀវ':
      return 'color_blue'.tr;
    case 'ក្រហម':
      return 'color_red'.tr;
    case 'មាស':
      return 'color_gold'.tr;
    default:
      return color;
  }
}

String localizedSize(String size) {
  return size.trim() == 'One Size' ? 'free_size'.tr : size;
}

String localizedErrorMessage(Object error) {
  final message = error.toString();
  final normalized = message.toLowerCase();
  if (normalized.contains('unauthorized') ||
      normalized.contains('invalid or expired token') ||
      normalized.contains('user not found') ||
      normalized.contains('not authenticated')) {
    return 'unauthorized'.tr;
  }
  if (message.contains('អ៊ីមែលនេះត្រូវបានប្រើរួចហើយ')) {
    return 'email_already_used'.tr;
  }
  if (message.contains('អ៊ីមែល ឬ ពាក្យសម្ងាត់ មិនត្រឹមត្រូវ')) {
    return 'invalid_credentials'.tr;
  }
  if (message.contains('ឈ្មោះមិនអាចទុកទទេ')) {
    return 'enter_name'.tr;
  }
  if (message.contains('ពាក្យសម្ងាត់បច្ចុប្បន្នមិនត្រឹមត្រូវ')) {
    return 'incorrect_current_password'.tr;
  }
  if (message.contains('ពាក្យសម្ងាត់ថ្មីត្រូវមានយ៉ាងតិច')) {
    return 'password_min_6'.tr;
  }
  if (message.contains('រកមិនឃើញផលិតផល')) {
    return 'product_not_found'.tr;
  }
  if (message.contains('ផលិតផលនេះអស់ស្តុក')) {
    return 'out_of_stock'.tr;
  }
  if (message.contains('រកមិនឃើញទំនិញក្នុងកន្ត្រក')) {
    return 'cart_item_not_found'.tr;
  }
  if (message.contains('បរិមាណត្រូវតែយ៉ាងហោចណាស់')) {
    return 'quantity_min_1'.tr;
  }
  if (message.contains('កន្ត្រករបស់អ្នកទទេ')) {
    return 'your_cart_is_empty'.tr;
  }
  if (message.contains('រកមិនឃើញអាសយដ្ឋាន')) {
    return 'address_not_found'.tr;
  }
  if (message.contains('សូមបញ្ចូលព័ត៌មានអាសយដ្ឋាន')) {
    return 'enter_address_info'.tr;
  }
  if (normalized.contains('timeout')) {
    return 'network_timeout'.tr;
  }
  if (normalized.contains('network error')) {
    return 'network_error'.tr;
  }
  if (normalized.contains('server error')) {
    return 'server_error'.tr;
  }
  return message;
}

class LocalizedText extends StatelessWidget {
  const LocalizedText({
    super.key,
    required this.khmer,
    required this.english,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String khmer;
  final String english;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LocaleController>()) {
      return Text(
        localizedContent(khmer: khmer, english: english),
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    return Obx(
      () => Text(
        localizedContent(khmer: khmer, english: english),
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      ),
    );
  }
}
