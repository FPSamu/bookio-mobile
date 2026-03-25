class Business {
  final int id;
  final String name;
  final String category;
  final String address;
  final String imageUrl;
  final List<String> services;

  Business({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.imageUrl,
    required this.services,
  });
}

class Appointment {
  final String id;
  final String businessName;
  final String service;
  final DateTime dateTime;
  final String status;
  final String? imageUrl;

  Appointment({
    required this.id,
    required this.businessName,
    required this.service,
    required this.dateTime,
    required this.status,
    this.imageUrl,
  });

  
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      businessName: json['businessName'],
      service: json['service'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
      imageUrl: json['imageUrl'],
    );
  }
}

class MockData {
  static final List<Business> businesses = [
    Business(
      id: 1,
      name: 'Peluquería Estilo',
      category: 'Salón de Belleza',
      address: 'Av. Patria 123',
      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=400',
      services: ['Corte de Cabello', 'Tinte', 'Manicura'],
    ),
    Business(
      id: 2,
      name: 'Dr. López - Dentista',
      category: 'Salud',
      address: 'Calle López Mateos 456',
      imageUrl: 'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?auto=format&fit=crop&q=80&w=400',
      services: ['Limpieza Dental', 'Extracción', 'Blanqueamiento'],
    ),
  ];

  static List<Appointment> appointments = [
    Appointment(
      id: '1',
      businessName: 'Sushi Place',
      service: 'Cena para 2',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      status: 'Confirmada',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvckX9gmBXYr9CUpxC5q8MZbUUaVtpTyTS6g&s',
    ),
    Appointment(
      id: '2',
      businessName: 'Italian Bistro',
      service: 'Comida',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Completada',
      imageUrl: 'https://www.pierrositalianbistro.com/wp-content/uploads/2024/03/2-slider.jpg',
    ),
    Appointment(
      id: '3',
      businessName: 'Steakhouse',
      service: 'Cena',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      status: 'Pendiente',
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3ooe8l9ztS6hUche00QmSZdnsiD_Y6hDhuQ&s',
    ),
  ];
}
