/// Data model representing a user's delivery address.
class AddressModel {
  /// Firestore Document ID (optional, used for updates/deletes).
  final String? id; 
  
  /// Full name of the recipient.
  final String fullName;
  
  /// Contact phone number for delivery.
  final String phoneNumber;
  
  /// Primary address line (e.g., Street name, House number).
  final String addressLine1;
  
  /// Secondary address line (e.g., Apartment, Suite, Landmark).
  final String addressLine2;
  
  /// City of the address.
  final String city;
  
  /// State or Province.
  final String state;
  
  /// Postal or Zip Code.
  final String zipCode;
  
  /// Indicates if this is the user's primary/default delivery address.
  final bool isDefault;

  AddressModel({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
  });

  /// Factory constructor to create an [AddressModel] from a Firestore document map.
  factory AddressModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AddressModel(
      id: documentId,
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      addressLine1: data['addressLine1'] ?? '',
      addressLine2: data['addressLine2'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  /// Converts the [AddressModel] instance into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }
}
