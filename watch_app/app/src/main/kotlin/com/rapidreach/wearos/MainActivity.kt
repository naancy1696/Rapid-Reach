package com.rapidreach.wearos

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.rapidreach.wearos.navigation.NavigationActionsImpl
import com.rapidreach.wearos.navigation.Screen
import com.rapidreach.wearos.ui.screens.*
import com.rapidreach.wearos.ui.theme.RapidReachTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            RapidReachTheme {
                RapidReachWearApp()
            }
        }
    }
}

/**
 * Main app composable with navigation
 */
@Composable
fun RapidReachWearApp() {
    val navController = rememberNavController()
    val navigationActions = NavigationActionsImpl(
        navigate = { route -> navController.navigate(route) },
        popBackStack = { navController.popBackStack() }
    )

    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route,
        modifier = Modifier.fillMaxSize()
    ) {
        // Splash Screen
        composable(Screen.Splash.route) {
            SplashScreen(
                onNavigateToHome = navigationActions::navigateToHome
            )
        }

        // Home Screen
        composable(Screen.Home.route) {
            HomeScreen(
                onNavigateToSensorStatus = navigationActions::navigateToSensorStatus,
                onNavigateToConnection = navigationActions::navigateToConnection,
                onNavigateToSOS = navigationActions::navigateToSOS,
                onNavigateToSettings = navigationActions::navigateToSettings
            )
        }

        // SOS Screen
        composable(Screen.SOS.route) {
            SosScreen(
                onNavigateBack = navigationActions::navigateBack
            )
        }

        // Sensor Status Screen
        composable(Screen.SensorStatus.route) {
            SensorStatusScreen(
                onNavigateBack = navigationActions::navigateBack
            )
        }

        // Connection Screen
        composable(Screen.Connection.route) {
            ConnectionScreen(
                onNavigateBack = navigationActions::navigateBack
            )
        }

        // Permissions Screen
        composable(Screen.Permissions.route) {
            PermissionsScreen(
                onNavigateBack = navigationActions::navigateBack
            )
        }

        // Settings Screen
        composable(Screen.Settings.route) {
            SettingsScreen(
                onNavigateToPermissions = navigationActions::navigateToPermissions,
                onNavigateBack = navigationActions::navigateBack
            )
        }
    }
}
