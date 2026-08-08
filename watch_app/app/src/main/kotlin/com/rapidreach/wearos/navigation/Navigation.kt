package com.rapidreach.wearos.navigation

/**
 * Routes for navigation in RapidReach Wear OS application
 * 
 * Navigation hierarchy:
 * Splash → Home → [Sensor Status, Connection, SOS, Permissions, Settings]
 */
sealed class Screen(val route: String) {
    object Splash : Screen("splash")
    object Home : Screen("home")
    object SensorStatus : Screen("sensor_status")
    object Connection : Screen("connection")
    object SOS : Screen("sos")
    object Permissions : Screen("permissions")
    object Settings : Screen("settings")
}

/**
 * Navigation actions for the app
 */
interface NavigationActions {
    fun navigateToHome()
    fun navigateToSensorStatus()
    fun navigateToConnection()
    fun navigateToSOS()
    fun navigateToPermissions()
    fun navigateToSettings()
    fun navigateBack()
}

/**
 * Implementation of navigation actions using NavController
 */
class NavigationActionsImpl(
    private val navigate: (String) -> Unit,
    private val popBackStack: () -> Unit
) : NavigationActions {
    override fun navigateToHome() = navigate(Screen.Home.route)
    override fun navigateToSensorStatus() = navigate(Screen.SensorStatus.route)
    override fun navigateToConnection() = navigate(Screen.Connection.route)
    override fun navigateToSOS() = navigate(Screen.SOS.route)
    override fun navigateToPermissions() = navigate(Screen.Permissions.route)
    override fun navigateToSettings() = navigate(Screen.Settings.route)
    override fun navigateBack() = popBackStack()
}
