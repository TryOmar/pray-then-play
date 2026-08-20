package com.praythenplay.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PtpMediumWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.ptp_widget_medium).apply {
                    val nextPrayer = widgetData.getString("next_prayer_name", "Salah") ?: "Salah"
                    val prayerTime = widgetData.getString("next_prayer_time", "--:--") ?: "--:--"
                    val countdown = widgetData.getString("countdown_text", "Next Salah") ?: "Next Salah"
                    val safetyVerdict = widgetData.getString("safety_verdict", "🟢 Safe to Play") ?: "🟢 Safe to Play"
                    val safetyDetail = widgetData.getString("safety_detail", "Checked with safe buffer") ?: "Checked with safe buffer"
                    val streakText = widgetData.getString("streak_text", "0d streak") ?: "0d streak"

                    setTextViewText(R.id.widget_prayer_title, "$nextPrayer at $prayerTime")
                    setTextViewText(R.id.widget_countdown_text, countdown)
                    setTextViewText(R.id.widget_safety_verdict, safetyVerdict)
                    setTextViewText(R.id.widget_safety_detail, safetyDetail)
                    setTextViewText(R.id.widget_streak_badge, "🔥 $streakText")

                    // Open App on Click
                    val launchIntent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("praythenplay://dashboard")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                    // Quick Queue Check Click
                    val checkIntent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("praythenplay://queue-check")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val checkPendingIntent = PendingIntent.getActivity(
                        context,
                        1,
                        checkIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_quick_check_btn, checkPendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {
                // Fallback default update
                val fallbackViews = RemoteViews(context.packageName, R.layout.ptp_widget_medium)
                appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
            }
        }
    }
}
