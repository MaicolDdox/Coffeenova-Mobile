<p align="center">
    <a href=""_blank>
      <img src="docs/assets/logoTipo.png" width="260" alt="Logo de CoffeeNova API">
    </a>
</p>

[![GitHub](https://img.shields.io/badge/GitHub-MaicolDdox-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MaicolDdox)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/maicol-duvan-gasca-rodas-4483923a4/?trk=public-profile-join-page)
[![Instagram](https://img.shields.io/badge/Instagram-@maicolddox__-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/maicolddox_?utm_source=qr&igsh=cTV6enRlMW05bjY3)
[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discordapp.com/users/1425631850453270543)
[![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/profile.php?id=61586710675179&sk=about_contact_and_basic_info)



<div align="center">
  <h1>CoffeeNova API</h1>
  <p>API REST para el catalogo de cafe, carrito y pedidos de la demo CoffeeNova.</p>
</div>

# CoffeeNova Mobile (Flutter)

## Descripcion

Aplicacion movil en Flutter para la demo CoffeeNova.
Consume la CoffeeNova API para catalogo, carrito y pedidos.
La navegacion y el estado siguen el stack declarado en `pubspec.yaml`.
Sin la API en ejecucion, las pantallas de datos no funcionaran.

> **Dependencia obligatoria:** esta app necesita la API Laravel 12 de CoffeeNova.
> Referencia oficial: https://github.com/MaicolDdox/Coffeenova-API?tab=readme-ov-file

## Tecnologias

- Flutter
- Dart (SDK ^3.9.2)
- cupertino_icons
- flutter_riverpod
- go_router
- dio
- shared_preferences
- google_fonts
- shimmer
- intl
- file_picker

## Requisitos

- Flutter SDK compatible con `environment: sdk: ^3.9.2`
- Android Studio o VS Code
- Emulador Android o dispositivo fisico

## Instalacion

```bash
git clone https://github.com/MaicolDdox/Coffeenova-Mobile.git
cd Coffeenova-Mobile
flutter pub get
```

## Configuracion de API Base URL (OBLIGATORIO)

La URL base se define en `lib/core/config/env.dart` mediante `EnvConfig.apiBaseUrl`.
Este proyecto no usa archivo `.env`.

Opciones de configuracion:

- Editar directamente `lib/core/config/env.dart` y ajustar el host base.
- Sobrescribir en tiempo de ejecucion con `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Valores por defecto (si no se define `API_BASE_URL`):

- Android emulador: `http://10.0.2.2:8000/api`
- Otras plataformas (desktop/iOS): `http://localhost:8000/api`

Notas importantes:

- En emulador Android, `localhost` apunta al emulador; usa `10.0.2.2`.
- En dispositivo fisico, usa la IP local de tu PC (ej: `http://192.168.1.50:8000/api`).

## Ejecutar

```bash
flutter run
```

## Conexion con la API (OBLIGATORIO)

Checklist antes de ejecutar la app:

- [ ] API Laravel 12 en ejecucion (ver README oficial)
- [ ] Migraciones y seeders ejecutados en la API (roles, admin/demo, etc.)
- [ ] CORS habilitado en la API si es necesario
- [ ] Base URL correcta en Flutter

Referencia oficial de la API:
https://github.com/MaicolDdox/Coffeenova-API?tab=readme-ov-file

## Build / Release

```bash
flutter build apk
```

## Troubleshooting

- La Base URL no incluye `/api` y devuelve 404 o rutas incorrectas.
- En emulador Android, usa `10.0.2.2` en lugar de `127.0.0.1`.
- En dispositivo fisico, usa la IP local del PC y la misma red Wi-Fi.
- La API no esta corriendo o no tiene migraciones/seeders aplicados.
- CORS bloquea las peticiones desde el cliente Flutter.
- Falta permiso de Internet en Android (`android/app/src/main/AndroidManifest.xml`).

## Creditos

- Autor: MaicolDdox
