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
import com.rapidreach.wearos.ui.components.StatusIndicator
import com.rapidreach.wearos.ui.theme.*

/**
 * Settings Screen
 *
 * Basic settings interface showing:
 * - Monitoring Status
 * - Watch Connection Status
 * - Permissions Link
 * - About RAPID REACH
 *
 * For Breakpoint 1: Settings are non-functional placeholders
 * Actual settings implementation deferred to Phase 2+
 */
@Composable
fun SettingsScreen(
    onNavigateToPermissions: () -> Unit,
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
                text = "SETTINGS",
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(4.dp))

            // Monitoring Setting
            SettingItem(
                label = "Monitoring",
                value = "Ready",
                onClick = { /* TODO: Implement in future phase */ }
            )

            // Connection Setting
            SettingItem(
                label = "Watch Connection",
                value = "Not Connected",
                onClick = { /* TODO: Implement in future phase */ }
            )

            // Permissions
            SettingItem(
                label = "Permissions",
                value = "View",
                onClick = onNavigateToPermissions
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Divider
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(BorderColor)
            )

            Spacer(modifier = Modifier.height(8.dp))

            // About Section
            SectionTitle(
                text = "ABOUT",
                modifier = Modifier.fillMaxWidth()
            )

            // Version info
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
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "App Name",
                            style = LabelSmall,
                            color = LightGray
                        )
                        Text(
                            text = "RAPID REACH",
                            style = BodySmall,
                            color = White
                        )
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Version",
                            style = LabelSmall,
                            color = LightGray
                        )
                        Text(
                            text = "1.0.0",
                            style = BodySmall,
                            color = White
                        )
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Module",
                            style = LabelSmall,
                            color = LightGray
                        )
                        Text(
                            text = "Wear OS",
                            style = BodySmall,
                            color = White
                        )
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "Phase",
                            style = LabelSmall,
                            color = LightGray
                        )
                        Text(
                            text = "Breakpoint 1",
                            style = BodySmall,
                            color = SuccessGreen
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Description
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        color = CardBackground,
                        shape = RoundedCornerShape(6.dp)
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
                        text = "AI-powered emergency response system companion app for Wear OS smartwatches.",
                        style = BodySmall,
                        color = LightGray,
                        textAlign = TextAlign.Start,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

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
 * Reusable setting item
 */
@Composable
fun SettingItem(
    label: String,
    value: String,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = CardBackground,
                shape = RoundedCornerShape(6.dp)
            )
            .clickable(onClick = onClick)
            .padding(10.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = label,
                style = LabelSmall,
                color = White,
                modifier = Modifier.weight(1f)
            )

            Text(
                text = value,
                style = BodySmall,
                color = LightGray
            )
        }
    }
}
