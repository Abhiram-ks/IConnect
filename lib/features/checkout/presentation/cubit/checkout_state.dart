part of 'checkout_cubit.dart';

enum CheckoutType { buyNow, cart }

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final CheckoutType checkoutType;
  final CartItemEntity? buyNowItem;
  final List<CartItemEntity> cartItems;

  // unique key to force state update even if data is same
  final String key;

  // User Details
  final String email;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String whatsappNumber;

  const CheckoutLoaded({
    required this.checkoutType,
    this.buyNowItem,
    this.cartItems = const [],
    this.key = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.address = '',
    this.city = '',
    this.whatsappNumber = '',
  });

  /// Dynamically return the correct items list based on checkout type
  List<CartItemEntity> get items {
    if (checkoutType == CheckoutType.buyNow && buyNowItem != null) {
      return [buyNowItem!];
    }
    return cartItems;
  }

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  CheckoutLoaded copyWith({
    CheckoutType? checkoutType,
    CartItemEntity? buyNowItem,
    List<CartItemEntity>? cartItems,
    String? key,
    String? email,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? whatsappNumber,
  }) {
    return CheckoutLoaded(
      checkoutType: checkoutType ?? this.checkoutType,
      buyNowItem: buyNowItem ?? this.buyNowItem,
      cartItems: cartItems ?? this.cartItems,
      key: key ?? this.key,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  @override
  List<Object?> get props => [
    checkoutType,
    buyNowItem,
    cartItems,
    key,
    email,
    firstName,
    lastName,
    address,
    city,
    whatsappNumber,
  ];
}
