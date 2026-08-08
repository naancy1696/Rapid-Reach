package com.rapidreach.wearos.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.ui.components.SectionTitle
import com.rapidreach.wearos.ui.theme.*

/**
 * Permissions Screen
 *
 * Educational screen explaining permissions that will be required:
 * - Body Sensors (for heart rate, SpO₂)
 * - Activity Recognition
 * - Notifications
 * - Bluetooth (for mobile connection)
 *
 * For Breakpoint 1: This is informational/UI only
 * No actual permission requests are implemented
 */
@Composable
fun PermissionsScreen(
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
                text = "PERMISSIONS",
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Info banner
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        color = CardBackground,
                        shape = RoundedCornerShape(8.dp)
                    )
                    .padding(8.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.Top
                ) {
                    Icon(
                        imageVector = Icons.Filled.Info,
                        contentDescription = "Info",
                        tint = PrimaryRed,
                        modifier = Modifier.size(14.dp)
                    )

                    Text(
                        text = "Permissions will be requested during setup in Phase 2.",
                        style = BodySmall,
                        color = LightGray,
                        textAlign = TextAlign.Start,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Permission Categories
            PermissionCategory(
                title = "Body Sensors",
                description = "For heart rate and SpO₂ monitoring",
                status = "Required"
            )

            PermissionCategory(
                title = "Activity Recognition",
                description = "For motion and fall detection",
                status = "Required"
            )

            PermissionCategory(
                title = "Notifications",
                description = "For emergency alerts",
                status = "Required"
            )

            PermissionCategory(
                title = "Bluetooth",
                description = "For mobile app connection",
                status = "Optional"
            )

            PermissionCategory(
                title = "Location",
                description = "For emergency location sharing",
                status = "Optional"
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Disclaimer
            Text(
                text = "RAPID REACH does not access any permissions until you explicitly grant them through the system settings.",
                style = BodySmall,
                color = MediumGray,
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

/**
 * Permission category item
 */
@Composable
fun PermissionCategory(
    title: String,
    description: String,
    status: String
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = CardBackground,
                shape = RoundedCornerShape(6.dp)
            )
            .padding(8.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    style = LabelSmall,
                    color = White,
                    modifier = Modifier.weight(1f)
                )

                Text(
                    text = status,
                    style = LabelSmall,
                    color = if (status == "Required") PrimaryRed else LightGray
                )
            }

            Text(
                text = description,
                style = BodySmall,
                color = LightGray,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
