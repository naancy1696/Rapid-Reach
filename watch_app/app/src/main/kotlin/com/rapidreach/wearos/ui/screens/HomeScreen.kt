package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Settings
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.model.WatchStatus
import com.rapidreach.wearos.ui.components.*
import com.rapidreach.wearos.ui.theme.*

/**
 * Home Screen
 *
 * Main dashboard showing:
 * - Watch status (Active/Inactive)
 * - Monitoring status
 * - Placeholder health metrics (Heart Rate, SpO2)
 * - Motion status
 * - Quick access to SOS and Settings
 */
@Composable
fun HomeScreen(
    onNavigateToSensorStatus: () -> Unit,
    onNavigateToConnection: () -> Unit,
    onNavigateToSOS: () -> Unit,
    onNavigateToSettings: () -> Unit
) {
    var watchStatus by remember { mutableStateOf(WatchStatus.ACTIVE) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Header
            SectionTitle(
                text = "RAPID REACH",
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 4.dp)
            )

            // Status indicator
            StatusIndicator(
                isActive = watchStatus == WatchStatus.ACTIVE,
                label = when (watchStatus) {
                    WatchStatus.ACTIVE -> "Watch Status: Active"
                    WatchStatus.INACTIVE -> "Watch Status: Inactive"
                    WatchStatus.LOADING -> "Initializing..."
                },
                modifier = Modifier.fillMaxWidth()
            )

            // Monitoring status
            StatusCard(
                label = "Monitoring",
                value = when (watchStatus) {
                    WatchStatus.ACTIVE -> "Ready"
                    else -> "Not Ready"
                },
                isActive = watchStatus == WatchStatus.ACTIVE
            )

            // Heart Rate placeholder
            StatusCard(
                label = "Heart Rate",
                value = "-- BPM",
                isActive = false,
                icon = Icons.Filled.Favorite
            )

            // SpO2 placeholder
            StatusCard(
                label = "SpO₂",
                value = "-- %",
                isActive = false
            )

            // Motion status placeholder
            StatusCard(
                label = "Motion",
                value = "Normal",
                isActive = false
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Divider
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(BorderColor)
            )

            Spacer(modifier = Modifier.height(4.dp))

            // SOS Quick Access Button
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        color = PrimaryRed,
                        shape = RoundedCornerShape(8.dp)
                    )
                    .clickable(onClick = onNavigateToSOS)
                    .padding(12.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "SOS",
                    style = DisplayMedium,
                    color = White,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Quick Links Row
            Row(
                modifier = Modifier
                    .fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                // Sensors Button
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(
                            color = SurfaceColor,
                            shape = RoundedCornerShape(6.dp)
                        )
                        .clickable(onClick = onNavigateToSensorStatus)
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Sensors",
                        style = LabelSmall,
                        color = White,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // Connection Button
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(
                            color = SurfaceColor,
                            shape = RoundedCornerShape(6.dp)
                        )
                        .clickable(onClick = onNavigateToConnection)
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Mobile",
                        style = LabelSmall,
                        color = White,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                // Settings Button
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .background(
                            color = SurfaceColor,
                            shape = RoundedCornerShape(6.dp)
                        )
                        .clickable(onClick = onNavigateToSettings)
                        .padding(8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Filled.Settings,
                        contentDescription = "Settings",
                        tint = White,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))
        }
    }
}
