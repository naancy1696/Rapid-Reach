package com.rapidreach.wearos.ui.theme

import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkMode
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.wear.compose.material.Colors
import androidx.wear.compose.material.MaterialTheme

/**
 * RapidReach Wear OS Theme
 * 
 * Professional emergency-response color scheme optimized for:
 * - Small circular displays
 * - AMOLED screens (dark theme)
 * - High contrast and readability
 * - Emergency action visibility
 */

private val RapidReachColors = Colors(
    primary = PrimaryRed,              // Emergency red
    primaryVariant = DarkRed,          // Darker variant for alternate use
    secondary = LightGray,             // Secondary actions
    secondaryVariant = MediumGray,     // Darker secondary
    background = DarkBackground,       // AMOLED-optimized dark background
    surface = SurfaceColor,            // Card and surface backgrounds
    error = ErrorRed,                  // Error/warning states
    onPrimary = OnPrimary,             // Text on primary red
    onSecondary = DarkBackground,      // Text on secondary
    onBackground = OnBackground,       // Text on background
    onSurface = OnSurface              // Text on surfaces
)

/**
 * RapidReach Material Theme
 * 
 * Apply this theme to all Composables in the app.
 * Handles colors, typography, and shapes.
 */
@Composable
fun RapidReachTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colors = RapidReachColors,
        content = content
    )
}

/**
 * Extension for applying background color with theme
 */
@Composable
fun Modifier.backgroundThemed(): Modifier =
    this.background(RapidReachColors.background)

/**
 * Extension for surface background
 */
@Composable
fun Modifier.surfaceThemed(): Modifier =
    this.background(RapidReachColors.surface)
