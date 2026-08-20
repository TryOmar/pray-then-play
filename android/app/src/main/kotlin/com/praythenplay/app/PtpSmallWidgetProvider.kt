package com.praythenplay.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PtpSmallWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.ptp_widget_small).apply {
                    val nextPrayer = widgetData.getString("next_prayer_name", "Salah") ?: "Salah"
                    val countdown = widgetData.getString("countdown_text", "On Time") ?: "On Time"
                    val safetyShort = widgetData.getString("safety_short", "🟢 SAFE") ?: "🟢 SAFE"
                    val safetyColorHex = widgetData.getString("safety_color_hex", "#10B981") ?: "#10B981"

                    setTextViewText(R.id.widget_small_prayer_name, nextPrayer)
                    setTextViewText(R.id.widget_small_countdown, countdown)
                    setTextViewText(R.id.widget_small_status, safetyShort)

                    try {
                        val parsedColor = Color.parseColor(safetyColorHex)
                        setTextColor(R.id.widget_small_status, parsedColor)
                    } catch (_: Exception) {}

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
                    setOnClickPendingIntent(R.id.widget_small_root, pendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {
                val fallbackViews = RemoteViews(context.packageName, R.layout.ptp_widget_small)
                appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
            }
        }
    }
}
