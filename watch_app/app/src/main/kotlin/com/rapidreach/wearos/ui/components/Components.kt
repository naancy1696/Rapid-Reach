package com.rapidreach.wearos.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.Icon
import androidx.wear.compose.material.Text
import com.rapidreach.wearos.ui.theme.*

/**
 * Reusable status card component for displaying status information
 * Used for heart rate, SpO2, motion, etc.
 */
@Composable
fun StatusCard(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
    isActive: Boolean = false,
    icon: ImageVector? = null
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(
                color = CardBackground,
                shape = RoundedCornerShape(8.dp)
            )
            .padding(12.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = label,
                style = LabelSmall,
                color = LightGray,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = value,
                style = HeadlineSmall,
                color = if (isActive) PrimaryRed else White,
                textAlign = TextAlign.Center
            )
            
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = label,
                    tint = if (isActive) SuccessGreen else LightGray,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

/**
 * Section title for organizing content
 */
@Composable
fun SectionTitle(
    text: String,
    modifier: Modifier = Modifier
) {
    Text(
        text = text,
        style = HeadlineLarge,
        color = PrimaryRed,
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        textAlign = TextAlign.Start
    )
}

/**
 * Status indicator showing if system is active/ready
 */
@Composable
fun StatusIndicator(
    isActive: Boolean,
    modifier: Modifier = Modifier,
    label: String? = null
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .background(
                    color = if (isActive) SuccessGreen else InactiveGray,
                    shape = RoundedCornerShape(50)
                )
        )
        
        if (label != null) {
            Text(
                text = label,
                style = BodySmall,
                color = if (isActive) SuccessGreen else LightGray
            )
        }
    }
}

/**
 * Wear OS optimized button for navigation
 */
@Composable
fun WearButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    isEmergency: Boolean = false,
    enabled: Boolean = true
) {
    Box(
        modifier = modifier
            .fillMaxWidth(0.9f)
            .background(
                color = if (isEmergency) PrimaryRed else SurfaceColor,
                shape = RoundedCornerShape(8.dp)
            )
            .padding(vertical = 12.dp, horizontal = 16.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = if (isEmergency) EmergencyAction else LabelLarge,
            color = if (isEmergency) White else White,
            textAlign = TextAlign.Center
        )
    }
}

/**
 * Wear OS large circular button for emergency actions
 */
@Composable
fun EmergencyActionButton(
    text: String,
    onPress: () -> Unit,
    onLongPress: () -> Unit,
    modifier: Modifier = Modifier,
    isActive: Boolean = false
) {
    Box(
        modifier = modifier
            .size(120.dp)
            .background(
                color = if (isActive) DarkRed else PrimaryRed,
                shape = RoundedCornerShape(50)
            )
            .padding(4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = DisplayMedium,
            color = White,
            textAlign = TextAlign.Center
        )
    }
}

/**
 * Connection status card with detailed information
 */
@Composable
fun ConnectionStatusCard(
    status: String,
    lastSync: String,
    isConnected: Boolean,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(
                color = CardBackground,
                shape = RoundedCornerShape(8.dp)
            )
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Status",
                style = LabelSmall,
                color = LightGray
            )
            
            Row(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .background(
                            color = if (isConnected) SuccessGreen else InactiveGray,
                            shape = RoundedCornerShape(50)
                        )
                )
                Text(
                    text = status,
                    style = BodySmall,
                    color = if (isConnected) SuccessGreen else LightGray
                )
            }
        }
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "Last Sync",
                style = LabelSmall,
                color = LightGray
            )
            
            Text(
                text = lastSync,
                style = BodySmall,
                color = White
            )
        }
    }
}

/**
 * Placeholder state indicator
 */
@Composable
fun PlaceholderValue(
    modifier: Modifier = Modifier
) {
    Text(
        text = "--",
        style = HeadlineSmall,
        color = MediumGray,
        modifier = modifier
    )
}
