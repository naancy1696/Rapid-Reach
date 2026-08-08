package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.model.SensorAvailability
import com.rapidreach.wearos.ui.components.SectionTitle
import com.rapidreach.wearos.ui.components.StatusCard
import com.rapidreach.wearos.ui.theme.*

/**
 * Sensor Status Screen
 *
 * Displays the availability status of various sensors:
 * - Heart Rate: Not Available (placeholder)
 * - SpO₂: Not Available (placeholder)
 * - Accelerometer: Ready
 * - Gyroscope: Ready
 *
 * For Breakpoint 1: All sensors display placeholder states only
 * No actual sensor access occurs
 */
@Composable
fun SensorStatusScreen(
    onNavigateBack: () -> Unit
) {
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
                text = "SENSOR STATUS",
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Heart Rate Sensor
            StatusCard(
                label = "Heart Rate",
                value = "Not Available",
                isActive = false
            )

            // SpO2 Sensor
            StatusCard(
                label = "SpO₂",
                value = "Not Available",
                isActive = false
            )

            // Accelerometer
            StatusCard(
                label = "Accelerometer",
                value = "Ready",
                isActive = true
            )

            // Gyroscope
            StatusCard(
                label = "Gyroscope",
                value = "Ready",
                isActive = true
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Info text
            Text(
                text = "Heart rate and SpO₂ sensors will be initialized in Phase 2 with proper sensor access and calibration.",
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
