package com.praythenplay.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PtpTimelineWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.ptp_widget_timeline).apply {
                    val nextPrayer = widgetData.getString("next_prayer_name", "Asr") ?: "Asr"
                    val countdown = widgetData.getString("countdown_text", "Salah Soon") ?: "Salah Soon"

                    val fajrTime = widgetData.getString("fajr_time", "04:52") ?: "04:52"
                    val dhuhrTime = widgetData.getString("dhuhr_time", "12:20") ?: "12:20"
                    val asrTime = widgetData.getString("asr_time", "15:45") ?: "15:45"
                    val maghribTime = widgetData.getString("maghrib_time", "18:30") ?: "18:30"
                    val ishaTime = widgetData.getString("isha_time", "20:00") ?: "20:00"

                    setTextViewText(R.id.widget_timeline_countdown, countdown)
                    setTextViewText(R.id.widget_fajr_time, fajrTime)
                    setTextViewText(R.id.widget_dhuhr_time, dhuhrTime)
                    setTextViewText(R.id.widget_asr_time, asrTime)
                    setTextViewText(R.id.widget_maghrib_time, maghribTime)
                    setTextViewText(R.id.widget_isha_time, ishaTime)

                    // Open Prayer Times screen on click
                    val launchIntent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("praythenplay://prayer-times")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        2,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_timeline_root, pendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {
                val fallbackViews = RemoteViews(context.packageName, R.layout.ptp_widget_timeline)
                appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
            }
        }
    }
}
