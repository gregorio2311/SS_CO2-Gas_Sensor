# API Endpoints - Sistema de Monitoreo IoT

## Endpoints REST

### Autenticación
- `POST /api/auth/register` - Registro de nuevo usuario
- `POST /api/auth/login` - Inicio de sesión
- `POST /api/auth/logout` - Cierre de sesión

### Usuarios
- `GET /api/users/me` - Obtener información del usuario actual
- `PUT /api/users/me` - Actualizar información del usuario
- `GET /api/users/:userId/devices` - Obtener dispositivos de un usuario
- `GET /api/users/:userId/shared-devices` - Obtener dispositivos compartidos con el usuario

### Dispositivos
- `POST /api/devices` - Registrar nuevo dispositivo
- `GET /api/devices/:deviceId` - Obtener información de un dispositivo
- `PUT /api/devices/:deviceId` - Actualizar información del dispositivo
- `DELETE /api/devices/:deviceId` - Eliminar dispositivo
- `GET /api/devices/:deviceId/sensors` - Obtener sensores de un dispositivo
- `PUT /api/devices/:deviceId/location` - Actualizar ubicación GPS del dispositivo
- `POST /api/devices/:deviceId/share` - Compartir dispositivo con otro usuario
- `PUT /api/devices/:deviceId/share/:userId` - Actualizar permisos de usuario compartido
- `DELETE /api/devices/:deviceId/share/:userId` - Revocar acceso compartido

### Sensores
- `GET /api/sensors/:sensorId` - Obtener información de un sensor
- `PUT /api/sensors/:sensorId` - Actualizar configuración del sensor
- `POST /api/sensors/:sensorId/calibrate` - Iniciar calibración del sensor
- `GET /api/sensors/:sensorId/calibration-status` - Obtener estado de calibración

## Endpoints WebSocket

### Conexión
- `ws://api/ws` - Conexión WebSocket base

### Eventos de Dispositivo
- `device:data` - Datos en tiempo real de un dispositivo
  ```json
  {
    "deviceId": "string",
    "timestamp": "ISO8601",
    "sensors": [
      {
        "sensorId": "string",
        "value": "number",
        "unit": "string"
      }
    ]
  }
  ```

### Eventos de Estado
- `device:status` - Estado de conexión del dispositivo
  ```json
  {
    "deviceId": "string",
    "status": "online|offline",
    "timestamp": "ISO8601"
  }
  ```

### Eventos de Calibración
- `sensor:calibration` - Estado de calibración de un sensor
  ```json
  {
    "sensorId": "string",
    "status": "in_progress|completed|failed",
    "progress": "number",
    "timestamp": "ISO8601"
  }
  ```

## Notas de Implementación

1. Todos los endpoints REST requieren autenticación mediante JWT en el header `Authorization: Bearer <token>`
2. Los endpoints WebSocket requieren el token JWT como parámetro de conexión
3. Las respuestas de error siguen el formato:
   ```json
   {
     "error": "string",
     "message": "string",
     "code": "number"
   }
   ```
4. Los endpoints de tiempo real (WebSocket) son preferibles para:
   - Datos de sensores en tiempo real
   - Estados de conexión de dispositivos
   - Progreso de calibración
5. Los endpoints REST son preferibles para:
   - Operaciones CRUD
   - Configuraciones
   - Gestión de permisos
   - Datos históricos 