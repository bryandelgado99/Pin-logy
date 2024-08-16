# Proyecto final Aplicaciones Móviles 
El presente proyecto se a desarrollado utilizando FLUTTER y se ha usado una base de datos en FIREBASE. Las funcionalidades implementadas en el proyecto son:

- Login con Firebase y con Gmail

- Registro con Firebase

- Barra de navegación

- Administración de usuarios (admin y user)

- Ubicación en tiempo real

- Ubicación en segundo plano

- Cálculo de área del polígono

## Integrantes

- Erika Alvarado

- Bryan Delgado

- Mateo Miño

## Despliegues


## Instalación
- Al clonar el presente proyecto podemos instalar todas las dependencias del proyecto con el comando flutter pub get

### Generar APK
- Para generar un apk usaremos el comando flutter [build apk --release] y buscar la APK generada en build/app/flutter-apk/

### Deploy Web
Primero ejecutar los siguientes comandos para poder tener las herramientas necesarias


```npm install -g firebase-tools```
 
``` npx firebase login ```

``` npx firebase hosting init ```

Configura tu página web en Firebase para permitir el uso de un dominio personalizado.

Agrega las variables web necesarias para el inicio de sesión en la web en tu archivo index.html. Estas variables se pueden obtener desde la configuración de Firebase.

Realiza el build de tu aplicación web para generar los archivos necesarios. Luego, copia el contenido generado en la carpeta public de tu proyecto.

Modifica el archivo firebase.json en tu proyecto para incluir el nombre personalizado de tu aplicación en la configuración de hosting.

- flutter deploy web

Finalmente luego de copiar el contenido de build/web a public ejecutamos el siguiente comando

- npx firebase deploy --only hosting:nombredesuproyecto



## Capturas de la Aplicación
###Login

![WhatsApp Image 2024-08-15 at 23 12 02 (4)](https://github.com/user-attachments/assets/7f525f84-ee38-45f6-a84d-d002197117a6)

###Inicio de Sesion de Usuario

![WhatsApp Image 2024-08-15 at 23 12 02 (3)](https://github.com/user-attachments/assets/aed033f1-34d1-4dc6-8345-8b62a0a6c040)

###Inicio de Sesion de Administrador

![WhatsApp Image 2024-08-15 at 23 12 02 (2)](https://github.com/user-attachments/assets/a97b4693-c87d-48e5-bcce-bfcf67d80df2)

###Opciones de Administrador

![WhatsApp Image 2024-08-15 at 23 12 02 (1)](https://github.com/user-attachments/assets/dc62ba07-a9b4-4f6c-a182-01ac998476f3)

###Formulario de Agregar Usuario

![WhatsApp Image 2024-08-15 at 23 12 02](https://github.com/user-attachments/assets/035b0b90-23e6-42ff-8646-4ad43006744a)

###Historial de Ubicaciones

![WhatsApp Image 2024-08-15 at 22 10 04 (2)](https://github.com/user-attachments/assets/81f34781-cea0-4d33-a601-5f9b814d64a3)

###Mapa de Ubicación de usuario

![WhatsApp Image 2024-08-15 at 22 10 04 (1)](https://github.com/user-attachments/assets/e25abc74-c45f-4fb6-910a-cb5d9d7e0a0e)

###Detalle de ubicacion e Área del polígono

![WhatsApp Image 2024-08-15 at 22 10 04](https://github.com/user-attachments/assets/5eebd6cf-cd38-42ff-8c43-2382e6a6f9bd)


