package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.ui.theme.*

/**
 * SOS Screen
 *
 * Emergency activation screen with:
 * - Large prominent SOS button
 * - Press-and-hold interaction for safety (prevent accidental activation)
 * - Clear warning message
 * - Demo confirmation message
 *
 * For Breakpoint 1: SOS button does NOT send real emergency
 * Shows only a local UI state confirmation
 */
@Composable
fun SosScreen(
    onNavigateBack: () -> Unit
) {
    var sosActivated by remember { mutableStateOf(false) }
    var isPressed by remember { mutableStateOf(false) }
    var countdown by remember { mutableStateOf(0) }

    // Handle press-and-hold for SOS activation
    LaunchedEffect(isPressed) {
        if (isPressed) {
            for (i in 3 downTo 1) {
                countdown = i
                kotlinx.coroutines.delay(1000L)
            }
            sosActivated = true
            isPressed = false
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(if (sosActivated) DarkRed else DarkBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Spacer(modifier = Modifier.height(8.dp))

            // Title
            Text(
                text = "EMERGENCY",
                style = DisplayLarge,
                color = PrimaryRed,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Instructions
            if (!sosActivated) {
                Text(
                    text = "Press and hold",
                    style = HeadlineSmall,
                    color = LightGray,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )

                Text(
                    text = "Emergency alert will be triggered",
                    style = BodySmall,
                    color = LightGray,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Large SOS Button
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .background(
                        color = if (sosActivated) DarkRed else PrimaryRed,
                        shape = CircleShape
                    )
                    .clickable { isPressed = !isPressed }
                    .padding(8.dp),
                contentAlignment = Alignment.Center
            ) {
                if (!sosActivated && countdown > 0) {
                    Text(
                        text = "$countdown",
                        style = DisplayLarge,
                        color = White,
                        textAlign = TextAlign.Center
                    )
                } else {
                    Text(
                        text = "SOS",
                        style = DisplayLarge,
                        color = White,
                        textAlign = TextAlign.Center
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Activated message
            if (sosActivated) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            color = SuccessGreen,
                            shape = RoundedCornerShape(8.dp)
                        )
                        .padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(
                            text = "SOS Demo",
                            style = HeadlineSmall,
                            color = DarkBackground,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )

                        Text(
                            text = "Feature coming in Phase 2",
                            style = BodySmall,
                            color = DarkBackground,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.fillMaxWidth()
                        )

                        Spacer(modifier = Modifier.height(4.dp))

                        // Back button
                        Box(
                            modifier = Modifier
                                .background(
                                    color = DarkBackground,
                                    shape = RoundedCornerShape(4.dp)
                                )
                                .clickable { onNavigateBack() }
                                .padding(6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "Back",
                                style = LabelSmall,
                                color = SuccessGreen,
                                textAlign = TextAlign.Center
                            )
                        }
                    }
                }
            } else {
                // Back button
                Box(
                    modifier = Modifier
                        .background(
                            color = SurfaceColor,
                            shape = RoundedCornerShape(6.dp)
                        )
                        .clickable { onNavigateBack() }
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Back",
                        style = LabelSmall,
                        color = White,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}
