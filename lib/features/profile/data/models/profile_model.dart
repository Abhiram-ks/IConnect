import 'package:iconnect/features/profile/domain/entities/profile_entity.dart';

/// Profile Model - Data layer representation with JSON serialization
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.defaultAddress,
    super.addresses,
  });

  /// Create ProfileModel from JSON response
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    if (customer == null) {
      throw Exception('Invalid JSON format for ProfileModel');
    }

    AddressEntity? defaultAddress;
    if (customer['defaultAddress'] != null) {
      defaultAddress = AddressModel.fromJson(customer['defaultAddress']);
    }

    List<AddressEntity> addresses = [];
    if (customer['addresses'] != null) {
      final addressesData = customer['addresses']['edges'] as List?;
      if (addressesData != null) {
        addresses = addressesData
            .map((edge) => AddressModel.fromJson(edge['node']))
            .toList();
      }
    }

    return ProfileModel(
      id: customer['id'] as String,
      email: customer['email'] as String? ?? '',
      firstName: customer['firstName'] as String?,
      lastName: customer['lastName'] as String?,
      phone: customer['phone'] as String?,
      defaultAddress: defaultAddress,
      addresses: addresses,
    );
  }

  /// Convert to ProfileEntity
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      defaultAddress: defaultAddress,
      addresses: addresses,
    );
  }
}

/// Address Model
class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    super.address1,
    super.address2,
    super.city,
    super.province,
    super.zip,
    super.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      zip: json['zip'] as String?,
      country: json['country'] as String?,
    );
  }
}

