package com.praythenplay.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PtpRecommendedWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.ptp_widget_recommended).apply {
                    val availableWindow = widgetData.getString("rec_window_text", "45m available") ?: "45m available"
                    val recName1 = widgetData.getString("rec_name_1", "Valorant") ?: "Valorant"
                    val recDetail1 = widgetData.getString("rec_detail_1", "Swiftplay • 15m") ?: "Swiftplay • 15m"
                    val recBadge1 = widgetData.getString("rec_badge_1", "SAFE") ?: "SAFE"

                    val recName2 = widgetData.getString("rec_name_2", "Rocket League") ?: "Rocket League"
                    val recDetail2 = widgetData.getString("rec_detail_2", "Casual 2v2 • 10m") ?: "Casual 2v2 • 10m"
                    val recBadge2 = widgetData.getString("rec_badge_2", "SAFE") ?: "SAFE"

                    setTextViewText(R.id.widget_rec_window, availableWindow)
                    setTextViewText(R.id.widget_rec_name_1, recName1)
                    setTextViewText(R.id.widget_rec_detail_1, recDetail1)
                    setTextViewText(R.id.widget_rec_badge_1, recBadge1)

                    setTextViewText(R.id.widget_rec_name_2, recName2)
                    setTextViewText(R.id.widget_rec_detail_2, recDetail2)
                    setTextViewText(R.id.widget_rec_badge_2, recBadge2)

                    // Open Queue Check on button click
                    val checkIntent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("praythenplay://queue-check")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val checkPendingIntent = PendingIntent.getActivity(
                        context,
                        3,
                        checkIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_rec_check_btn, checkPendingIntent)
                    setOnClickPendingIntent(R.id.widget_recommended_root, checkPendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {
                val fallbackViews = RemoteViews(context.packageName, R.layout.ptp_widget_recommended)
                appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
            }
        }
    }
}
