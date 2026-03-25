# Bookio - Mobile

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://www.android.com/)
[![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://www.apple.com/ios/)

Bienvenido al repositorio Mobile de **Bookio**.

## 🔗 Ecosistema Bookio
Esta plataforma cuenta con una arquitectura desacoplada. Explora nuestros diferentes repositorios:

* 🌐 [**Frontend (Angular SPA)** ➔ Visitar Repositorio](https://github.com/FPSamu/bookio-frontend)
* 📱 [**Mobile App (Cliente iOS/Android con Flutter)** ➔ Estás aquí](https://github.com/FPSamu/bookio-mobile)
* ⚙️ [**Backend (API REST Node.js)** ➔ Visitar Repositorio](https://github.com/AlanDVarela/bookio-backend)

---

## 📖 Descripción del Proyecto
Actualmente, muchas Pequeñas y Medianas Empresas (PyMEs) del sector servicios (barberías, spas, consultorios) gestionan sus citas de manera manual. Esto ocasiona problemas críticos como el empalme de horarios (*overbooking*), altas tasas de ausentismo (*no-shows*) y pérdida de tiempo productivo en la gestión telefónica.

**Bookio** es una plataforma web y móvil multi-negocio diseñada para resolver esta problemática. Nuestra aplicación móvil (cliente iOS/Android) brinda a los clientes una vía rápida e intuitiva para explorar negocios "Cerca de ti", ver disponibilidad en tiempo real y agendar citas. Además, permite a los dueños de negocios gestionar su perfil y acceder a sus configuraciones básicas.

### 👥 Equipo 
* **Alan Varela**
* **Samuel Pia**
* **Benjamin Rodriguez** 

---

## 📱 Flujos de la Aplicación Móvil
El desarrollo de la aplicación se centra en flujos principales diseñados para brindar una excelente experiencia de usuario (UX):

1. **Flujo 1 - Autenticación y Autorización:** Registro e inicio de sesión interactivo dependiente del rol seleccionado (Cliente o Dueño de Negocio).
2. **Flujo 2 - Exploración y Búsqueda (Cliente):** Vista principal que muestra categorías, negocios recomendados y cercanos, aplicando filtros y diseño en tarjetas (*cards*).
3. **Flujo 3 - Agendamiento de Citas:** Interfaz fluida para la visualización de detalles del negocio (usando `SliverAppBar`), revisión de métricas (`table_calendar`) y selección ágil de horarios.
4. **Flujo 4 - Gestión del Negocio (Dueño):** Pantalla de configuración avanzada con opciones para editar servicios, personal, galería y soporte a la funcionalidad Global de Modo Oscuro.

### Arquitectura de Presentación
La aplicación está construida utilizando **Flutter** y respeta una estricta separación de responsabilidades:
* **`lib/screens/`**: Vistas organizadas por dominio funcional (ej. `auth`, `client`, `business`, `common`).
* **`lib/widgets/`**: Componentes visuales reutilizables.
* **`lib/theme/`**: Administración general del tema para implementar una interfaz unificada (Dark/Light mode).

---

## ⚙️ Cómo correr el proyecto (Local)

### Prerrequisitos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado
* Entorno configurado para Android Studio o Xcode
* Dispositivo físico o emulador/simulador

### Pasos de instalación
1. Clona el repositorio:
   ```bash
   git clone https://github.com/FPSamu/bookio-mobile.git
   cd bookio-mobile
   ```
2. Descarga e instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

*Nota: Para verificar que tu entorno se encuentra listo, puedes usar el comando `flutter doctor`.*
