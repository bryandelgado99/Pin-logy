# Proyecto final Aplicaciones Móviles 
El presente proyecto se a desarrollado utilizando FLUTTER y se ha usado una base de datos en FIREBASE. Las funcionalidades implementadas en el proyecto son:

-Login con Firebase y con Gmail

-Registro con Firebase

-Barra de navegación

Administración de usuarios (admin y user)

Ubicación en tiempo real

Ubicación en segundo plano

Cálculo de área del polígono

## Integrantes

-Erika Alvarado

-Bryan Delgado

-Mateo Miño

## Instalación
-Al clonar el presente proyecto podemos instalar todas las dependencias del proyecto con el comando flutter pub get
Generar APK
-Para generar un apk usaremos el comando flutter (build apk --release) y buscar la APK generada en build/app/flutter-apk/

Deploy Web
Primero ejecutar los siguientes comandos para poder tener las herramientas necesarias
-npm install -g firebase-tools

-npx firebase login

-npx firebase hosting init

Configura tu página web en Firebase para permitir el uso de un dominio personalizado.

Agrega las variables web necesarias para el inicio de sesión en la web en tu archivo index.html. Estas variables se pueden obtener desde la configuración de Firebase.

Realiza el build de tu aplicación web para generar los archivos necesarios. Luego, copia el contenido generado en la carpeta public de tu proyecto.

Modifica el archivo firebase.json en tu proyecto para incluir el nombre personalizado de tu aplicación en la configuración de hosting.

flutter deploy web

Finalmente luego de copiar el contenido de build/web a public ejecutamos el siguiente comando

npx firebase deploy --only hosting:nombredesuproyecto



## Capturas de la Aplicación
Login

Historial de Ubicaciones

![WhatsApp Image 2024-08-15 at 22 10 04 (2)](https://github.com/user-attachments/assets/81f34781-cea0-4d33-a601-5f9b814d64a3)

Mapa de Ubicación de usuario

![WhatsApp Image 2024-08-15 at 22 10 04 (1)](https://github.com/user-attachments/assets/e25abc74-c45f-4fb6-910a-cb5d9d7e0a0e)

Detalle de ubicacion e Área del polígono

![WhatsApp Image 2024-08-15 at 22 10 04](https://github.com/user-attachments/assets/5eebd6cf-cd38-42ff-8c43-2382e6a6f9bd)


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
