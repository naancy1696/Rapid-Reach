package com.rapidreach.wearos.model

/**
 * Watch status - Indicates whether the watch app is actively monitoring
 */
enum class WatchStatus {
    ACTIVE,      // Currently monitoring
    INACTIVE,    // Not monitoring
    LOADING      // Starting up
}

/**
 * Connection status - Indicates connection with mobile app
 */
enum class ConnectionStatus {
    CONNECTED,        // Connected to mobile
    DISCONNECTED,     // Not connected
    CONNECTING,       // Currently connecting
    NOT_AVAILABLE     // Not applicable
}

/**
 * Sensor data availability (placeholder for UI)
 */
enum class SensorAvailability {
    AVAILABLE,        // Sensor is available and ready
    NOT_AVAILABLE,    // Sensor not available on this device
    INITIALIZING      // Sensor is starting up
}

/**
 * Overall device motion status (placeholder)
 */
enum class MotionStatus {
    NORMAL,           // Normal activity
    ELEVATED,         // Increased movement
    INACTIVE          // No movement
}

/**
 * Application permission categories
 */
enum class PermissionCategory {
    BODY_SENSORS,
    ACTIVITY_RECOGNITION,
    NOTIFICATIONS,
    BLUETOOTH,
    LOCATION,
    BATTERY_OPTIMIZATION
}

/**
 * Permission status
 */
enum class PermissionStatus {
    GRANTED,          // Permission granted
    DENIED,           // Permission denied
    NOT_REQUESTED     // Not requested yet
}
