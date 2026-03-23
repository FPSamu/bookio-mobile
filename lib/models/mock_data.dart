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
  final int id;
  final String businessName;
  final String service;
  final String dateTime;

  Appointment({
    required this.id,
    required this.businessName,
    required this.service,
    required this.dateTime,
  });
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

  static final List<Appointment> appointments = [
    Appointment(
      id: 1,
      businessName: 'Peluquería Estilo',
      service: 'Corte de Cabello',
      dateTime: '2023-11-20 10:00 AM', // Simulated date
    )
  ];
}
