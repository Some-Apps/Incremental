package me.jareddanieljones.sharedcause

import android.app.Application
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ServerTimestamp
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import java.util.Calendar
import java.util.Date


class MainActivity : ComponentActivity() {

    private lateinit var authViewModel: AuthViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Firebase
        FirebaseApp.initializeApp(this)

        // Initialize your ViewModel after Firebase is initialized
        authViewModel = AuthViewModel()

        setContent {
            ContentView(authViewModel)
        }
    }
}

@Composable
fun ContentView(authViewModel: AuthViewModel) {
    val user by authViewModel.user.collectAsState()

    if (user != null) {
        MainView(authViewModel)
    } else {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text("Signing in...")
        }
    }
}

@Composable
fun MainView(authViewModel: AuthViewModel) {
    val userViewModel: UserViewModel = viewModel(
        factory = UserViewModelFactory(authViewModel)
    )
    val needsToSelectVegetarianType by userViewModel.needsToSelectVegetarianType.collectAsState()
    val userData by userViewModel.userData.collectAsState()

    when {
        needsToSelectVegetarianType -> {
            VegetarianTypeSelectionView(userViewModel)
        }
        userData != null -> {
            StreakView(userViewModel, userData!!)
        }
        else -> {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                Text("Loading...")
            }
        }
    }
}

@Composable
fun CardView(title: String, value: String) {
    Column(
        verticalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier
            .padding()
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surfaceVariant, shape = MaterialTheme.shapes.medium)
            .padding(16.dp)
    ) {
        Text(title, style = MaterialTheme.typography.titleMedium)
        Text(value, style = MaterialTheme.typography.headlineMedium)
    }
}

@Composable
fun StreakView(userViewModel: UserViewModel, userData: Vegetarian) {
    val activeUserCount by userViewModel.activeUserCount.collectAsState()
    var showingConfirmation by remember { mutableStateOf(false) }
    var confirmReportSetback by remember { mutableStateOf(false) }
    var confirmDecision by remember { mutableStateOf(false) }
    var showingTypeSelection by remember { mutableStateOf(false) }
    var currentTime by remember { mutableStateOf(Date()) }

    // Timer to update current time
    LaunchedEffect(Unit) {
        while (true) {
            currentTime = Date()
            kotlinx.coroutines.delay(1000L)
        }
    }

    val timeUntilNextReport = remember(currentTime) {
        computeTimeUntilNextReport(userData.needsToReportBy, currentTime)
    }

    // UI
    Column(
        modifier = Modifier.fillMaxSize()
    ) {
        if (activeUserCount != null) {
            Text(
                "Active ${userData.vegetarianType.displayName}s: $activeUserCount",
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        } else {
            Text(
                "Loading active users...",
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        // Scrollable content
        Column(
            verticalArrangement = Arrangement.spacedBy(25.dp),
            modifier = Modifier
                .weight(1f)
                .padding(16.dp)
        ) {
            Text(
                "Welcome, ${userData.vegetarianType.displayName}!",
                style = MaterialTheme.typography.headlineLarge
            )

            CardView(title = "Current Streak", value = "${userData.currentStreak} days")
            CardView(title = "Best Streak", value = "${userData.bestStreak} days")

            // Report Card
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.surfaceVariant, shape = MaterialTheme.shapes.medium)
                    .padding(16.dp)
            ) {
                IconButton(onClick = { confirmReportSetback = true }) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Report Setback",
                        tint = MaterialTheme.colorScheme.error
                    )
                }

                Spacer(modifier = Modifier.weight(1f))

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("Report Within", style = MaterialTheme.typography.titleMedium)
                    Text(timeUntilNextReport, style = MaterialTheme.typography.headlineMedium)
                }

                Spacer(modifier = Modifier.weight(1f))

                IconButton(onClick = { confirmDecision = true }) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Report In",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }

        // Change Vegetarian Type Button
        TextButton(onClick = { showingConfirmation = true }) {
            Text("Change Vegetarian Type")
        }

        // Confirmation Dialogs
        if (showingConfirmation) {
            AlertDialog(
                onDismissRequest = { showingConfirmation = false },
                title = { Text("Change Vegetarian Type") },
                text = {
                    Text("Changing your vegetarian type will reset your current streak. Do you wish to proceed?")
                },
                confirmButton = {
                    TextButton(onClick = {
                        showingConfirmation = false
                        showingTypeSelection = true
                    }) {
                        Text("Yes, Change Type")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showingConfirmation = false }) {
                        Text("Cancel")
                    }
                }
            )
        }

        if (confirmDecision) {
            AlertDialog(
                onDismissRequest = { confirmDecision = false },
                text = {
                    Text("Are you dedicated to keeping a ${userData.vegetarianType.displayName} diet?")
                },
                confirmButton = {
                    TextButton(onClick = {
                        confirmDecision = false
                        userViewModel.reportIn()
                    }) {
                        Text("Confirm")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { confirmDecision = false }) {
                        Text("Cancel")
                    }
                }
            )
        }

        if (confirmReportSetback) {
            AlertDialog(
                onDismissRequest = { confirmReportSetback = false },
                text = { Text("Are you sure you want to report a setback?") },
                confirmButton = {
                    TextButton(onClick = {
                        confirmReportSetback = false
                        userViewModel.reportSetback()
                    }) {
                        Text("Confirm")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { confirmReportSetback = false }) {
                        Text("Cancel")
                    }
                }
            )
        }

        if (showingTypeSelection) {
            VegetarianTypeSelectionView(userViewModel) {
                showingTypeSelection = false
            }
        }
    }
}

fun computeTimeUntilNextReport(needsToReportBy: Date, currentTime: Date): String {
    val interval = needsToReportBy.time - currentTime.time
    return if (interval <= 0) {
        "00:00:00:00"
    } else {
        val totalSeconds = interval / 1000
        val days = totalSeconds / 86400
        val hours = (totalSeconds % 86400) / 3600
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60

        when {
            totalSeconds < 60 -> "$seconds seconds"
            totalSeconds < 3600 -> "$minutes minutes"
            totalSeconds < 86400 -> "$hours hours"
            else -> "$days days"
        }
    }
}

@Composable
fun VegetarianTypeSelectionView(
    userViewModel: UserViewModel,
    onDismiss: () -> Unit = {}
) {
    var selectedType by remember { mutableStateOf(userViewModel.userData.value?.vegetarianType ?: VegetarianType.VEGETARIAN) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Select Your Vegetarian Type") },
        text = {
            LazyColumn {
                items(VegetarianType.values().size) { index ->
                    val type = VegetarianType.values()[index]
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedType = type }
                            .padding(vertical = 8.dp)
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(type.displayName, style = MaterialTheme.typography.titleMedium)
                            Text(type.description, style = MaterialTheme.typography.bodySmall)
                        }
                        if (selectedType == type) {
                            Icon(
                                imageVector = Icons.Default.Check,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                if (userViewModel.needsToSelectVegetarianType.value == true) {
                    userViewModel.saveInitialUserData(selectedType)
                } else {
                    userViewModel.changeVegetarianType(selectedType)
                }
                onDismiss()
            }) {
                Text("Continue")
            }
        }
    )
}

class UserViewModel(private val authViewModel: AuthViewModel) : ViewModel() {
    private val db = FirebaseFirestore.getInstance()
    private val _userData = MutableStateFlow<Vegetarian?>(null)
    val userData: StateFlow<Vegetarian?> = _userData

    private val _needsToSelectVegetarianType = MutableStateFlow(false)
    val needsToSelectVegetarianType: StateFlow<Boolean> = _needsToSelectVegetarianType

    private val _activeUserCount = MutableStateFlow<Int?>(null)
    val activeUserCount: StateFlow<Int?> = _activeUserCount


    init {
        fetchUserData()
    }

    private fun fetchUserData() {
        val userID = authViewModel.user.value?.uid ?: return

        db.collection("users").document(userID)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    // Handle error
                    return@addSnapshotListener
                }

                if (snapshot != null && snapshot.exists()) {
                    val userData = snapshot.toObject(Vegetarian::class.java)
                    if (userData != null) {
                        // Handle missed reporting deadline and update streak
                        handleUserData(userData)
                    }
                } else {
                    _needsToSelectVegetarianType.value = true
                }
            }
    }

    private fun handleUserData(userData: Vegetarian) {
        // Implement the logic similar to your Swift code
        // Update _userData, sharedPreferences, etc.
        _userData.value = userData
    }

    fun saveInitialUserData(vegetarianType: VegetarianType) {
        val userID = authViewModel.user.value?.uid ?: return
        val newUser = Vegetarian(vegetarianType = vegetarianType)
        db.collection("users").document(userID)
            .set(newUser)
            .addOnSuccessListener {
                _userData.value = newUser
                _needsToSelectVegetarianType.value = false
            }
    }

    fun reportIn() {
        // Update lastReportDate and needsToReportBy
    }

    fun reportSetback() {
        // Reset streak due to setback
    }

    fun changeVegetarianType(newType: VegetarianType) {
        // Change vegetarian type and reset streak
    }

    fun fetchActiveUserCount() {
        // Fetch active user count from Firestore
    }
}

class UserViewModelFactory(private val authViewModel: AuthViewModel) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(UserViewModel::class.java)) {
            return UserViewModel(authViewModel) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
class AuthViewModel : ViewModel() {
    private val firebaseAuth = FirebaseAuth.getInstance()
    private val _user = MutableStateFlow<FirebaseUser?>(firebaseAuth.currentUser)
    val user: StateFlow<FirebaseUser?> = _user

    init {
        firebaseAuth.addAuthStateListener { auth ->
            _user.value = auth.currentUser
            if (auth.currentUser == null) {
                signInAnonymously()
            }
        }
    }

    private fun signInAnonymously() {
        firebaseAuth.signInAnonymously()
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    _user.value = firebaseAuth.currentUser
                } else {
                    // Handle sign-in error
                }
            }
    }
}

enum class VegetarianType(val displayName: String, val description: String) {
    VEGAN(
        "Vegan",
        "Excludes all animal products, including meat, dairy, eggs, and honey."
    ),
    VEGETARIAN(
        "Vegetarian",
        "Excludes meat and fish but may include dairy and eggs."
    ),
    PESCATARIAN(
        "Pescatarian",
        "Excludes meat but includes fish and seafood."
    ),
    FLEXITARIAN(
        "Flexitarian",
        "Primarily vegetarian but occasionally includes meat or fish."
    )
}

data class Vegetarian(
    val vegetarianType: VegetarianType = VegetarianType.VEGETARIAN,
    val bestStreak: Int = 0,
    @ServerTimestamp val lastReportDate: Date = Date(),
    val needsToReportBy: Date = Calendar.getInstance().apply {
        add(Calendar.DAY_OF_YEAR, 7)
    }.time,
    val lastSetbackDate: Date? = Date()
) {
    val currentStreak: Int
        get() {
            val referenceDate = lastSetbackDate ?: Date(0)
            val days = ((Date().time - referenceDate.time) / (1000 * 60 * 60 * 24)).toInt()
            return maxOf(days, 0)
        }

    val isActive: Boolean
        get() = Date() <= needsToReportBy

    val timeUntilNextReport: String
        get() = computeTimeUntilNextReport(needsToReportBy, Date())
}


