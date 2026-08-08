package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.ui.components.ConnectionStatusCard
import com.rapidreach.wearos.ui.components.SectionTitle
import com.rapidreach.wearos.ui.theme.*

/**
 * Connection Status Screen
 *
 * Displays mobile app connection status:
 * - Connection Status: Not Connected (placeholder)
 * - Last Sync: --:--:-- (placeholder)
 * - Reconnect button (shows demo message in Breakpoint 1)
 *
 * For Breakpoint 1: Connection remains a placeholder
 * No actual Bluetooth or Data Layer communication
 */
@Composable
fun ConnectionScreen(
    onNavigateBack: () -> Unit
) {
    var reconnectClicked by remember { mutableStateOf(false) }

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
                text = "MOBILE CONNECTION",
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Connection Status Card
            ConnectionStatusCard(
                status = "Not Connected",
                lastSync = "--:--:--",
                isConnected = false
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Reconnect Button
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.9f)
                    .align(Alignment.CenterHorizontally)
                    .background(
                        color = if (reconnectClicked) SuccessGreen else PrimaryRed,
                        shape = RoundedCornerShape(8.dp)
                    )
                    .clickable { reconnectClicked = !reconnectClicked }
                    .padding(12.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "Reconnect",
                    style = LabelLarge,
                    color = if (reconnectClicked) DarkBackground else White,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Status message
            if (reconnectClicked) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            color = CardBackground,
                            shape = RoundedCornerShape(8.dp)
                        )
                        .padding(12.dp)
                ) {
                    Text(
                        text = "Connection feature coming in Phase 2\n\nWear OS Data Layer will enable watch-to-mobile communication with proper synchronization.",
                        style = BodySmall,
                        color = LightGray,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Info text
            Text(
                text = "Bluetooth and Wear OS Data Layer integration will be implemented in Phase 2.",
                style = BodySmall,
                color = LightGray,
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp)
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Back button
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.9f)
                    .align(Alignment.CenterHorizontally)
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

            Spacer(modifier = Modifier.height(4.dp))
        }
    }
}
