import 'package:equatable/equatable.dart';

/// Brand Entity - Pure business object
class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String vendor;
  final String? imageUrl;

  const BrandEntity({
    required this.id,
    required this.name,
    required this.vendor,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, vendor, imageUrl];
}

