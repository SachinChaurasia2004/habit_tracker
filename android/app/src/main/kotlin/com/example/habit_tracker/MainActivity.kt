package com.example.habit_tracker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onResume() {
        super.onResume()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)
            
            val channel = NotificationChannel(
                "streak_channel",
                "Streak Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for habit streaks and reminders"
            }
            
            notificationManager.createNotificationChannel(channel)
        }
    }
}
