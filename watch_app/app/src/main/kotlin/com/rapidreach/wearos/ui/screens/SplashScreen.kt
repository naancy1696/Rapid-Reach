package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.ui.theme.*
import kotlinx.coroutines.delay

/**
 * Splash Screen
 * 
 * Shows RAPID REACH branding briefly before entering the Home screen.
 * Automatically navigates to Home after delay.
 */
@Composable
fun SplashScreen(
    onNavigateToHome: () -> Unit
) {
    // Auto-navigate to home after 2 seconds
    LaunchedEffect(Unit) {
        delay(2000L)
        onNavigateToHome()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(16.dp)
        ) {
            // App Name
            Text(
                text = "RAPID REACH",
                style = DisplayLarge,
                color = PrimaryRed,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Tagline
            Text(
                text = "Emergency Response",
                style = HeadlineSmall,
                color = LightGray,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Loading indicator (simple dot)
            Box(
                modifier = Modifier
                    .size(4.dp)
                    .background(SuccessGreen, shape = androidx.compose.foundation.shape.CircleShape)
            )
        }
    }
}
