package com.rapidreach.wearos.ui.theme

import androidx.compose.ui.graphics.Color

// Primary Colors - Emergency Red Theme
val PrimaryRed = Color(0xFFE63946)        // Emergency red
val DarkRed = Color(0xFFB91C1C)           // Darker red for accents
val LightRed = Color(0xFFFF6B6B)          // Lighter red for highlights

// Secondary Colors - Professional Neutral
val DarkBackground = Color(0xFF0F0F0F)    // Almost black for AMOLED
val SurfaceColor = Color(0xFF1A1A1A)      // Surface color
val White = Color(0xFFFFFFFF)             // White text
val LightGray = Color(0xFFBCBCBC)         // Secondary text
val MediumGray = Color(0xFF666666)        // Tertiary text

// Status Colors
val SuccessGreen = Color(0xFF2ECC71)      // Positive status
val WarningOrange = Color(0xFFF39C12)     // Warning status
val ErrorRed = Color(0xFFE74C3C)          // Error status
val InactiveGray = Color(0xFF404040)      // Inactive/placeholder

// Semantic Colors
val OnPrimary = White                     // Text on primary red
val OnSurface = White                     // Text on surface
val OnBackground = White                  // Text on background

// Wear OS Specific
val CardBackground = Color(0xFF1F1F1F)    // Card background for contrast
val BorderColor = Color(0xFF333333)       // Subtle borders

// Status Indicators
val ActiveStatus = SuccessGreen           // When monitoring
val IdleStatus = InactiveGray             // When idle
val AlertStatus = PrimaryRed              // Emergency state
