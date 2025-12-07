import 'package:equatable/equatable.dart';

/// Profile Entity - Domain layer representation of customer profile data
class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final AddressEntity? defaultAddress;
  final List<AddressEntity> addresses;

  const ProfileEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.defaultAddress,
    this.addresses = const [],
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        defaultAddress,
        addresses,
      ];
}

/// Address Entity
class AddressEntity extends Equatable {
  final String id;
  final String? address1;
  final String? address2;
  final String? city;
  final String? province;
  final String? zip;
  final String? country;

  const AddressEntity({
    required this.id,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.zip,
    this.country,
  });

  String get fullAddress {
    final parts = <String>[];
    if (address1 != null && address1!.isNotEmpty) parts.add(address1!);
    if (address2 != null && address2!.isNotEmpty) parts.add(address2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    if (zip != null && zip!.isNotEmpty) parts.add(zip!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        address1,
        address2,
        city,
        province,
        zip,
        country,
      ];
}

