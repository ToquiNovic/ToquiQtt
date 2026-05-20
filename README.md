# ToquiMQTT 🚀

**ToquiMQTT** es una aplicación cliente MQTT profesional desarrollada
con Flutter. Está diseñada para el monitoreo y gestión de brokers en
tiempo real, utilizando una arquitectura limpia y reactiva basada en el
patrón **BLoC**.

---

## 📁 Estructura del Proyecto

El código está organizado siguiendo principios de separación de
responsabilidades (Clean Architecture) para facilitar su escalabilidad:

```text
lib/
├── core/
│   └── theme/            # Estilos y temas visuales (toqui_styles.dart)
├── data/
│   ├── models/           # Modelos de datos (broker_model.dart)
│   └── repositories/     # Manejo de persistencia (broker_repository.dart)
├── logic/
│   └── blocs/            # Lógica de negocio y estados (mqtt_bloc.dart, broker_bloc.dart)
└── presentation/
    ├── components/       # Componentes UI reutilizables y guards de estado
    ├── screens/          # Pantallas principales (home_screen.dart, topics_screen.dart)
    └── widgets/
        └── topics/       # Widgets especializados para la vista de mensajes y tópicos
```

---

## ✨ Características

- **Gestión de Brokers:** Registro, edición y persistencia de
  múltiples brokers (Host, Puerto, ID).
- **Conexión en Tiempo Real:** Estados de conexión dinámicos
  gestionados por BLoC (Connecting, Connected, Faulted).
- **Suscripción Dinámica:** Interfaz para añadir tópicos con soporte
  para wildcards de MQTT (`#`, `+`).
- **Monitoreo de Mensajes:** Visualización en tiempo real de los
  últimos mensajes recibidos por tópico.
- **Null-Safety:** Implementación de guards para prevenir errores de
  punteros nulos durante la conexión.

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter\
- **Gestión de Estado:** Flutter BLoC\
- **Protocolo de Red:** MQTT Client\
- **Logging:** `dart:developer` para trazabilidad profesional sin
  afectar el rendimiento en producción

---

## 🚀 Instalación y Uso

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/ToquiNovic/ToquiQTT
```

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

### 3️⃣ Ejecutar la app

```bash
flutter run
```

---

## 📝 Notas de Depuración (Logs)

Para facilitar el desarrollo, el `MqttBloc` emite logs detallados
visibles en la Debug Console del IDE:

- `[MQTT_BLOC] Iniciando conexión` → Intento de handshake con el host.
- `[MQTT_BLOC] Conexión establecida` → Confirmación de enlace exitoso.
- `[MQTT_BLOC] Mensaje recibido` → Tópico y payload de cada paquete
  entrante.
- `[MQTT_BLOC] Error` → Fallos de red o autenticación.

---

Desarrollado con enfoque en **Clean Architecture** y **reactividad
profesional**. 📱✨
