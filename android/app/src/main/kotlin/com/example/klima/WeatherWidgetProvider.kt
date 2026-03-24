package com.example.klima

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
                val location = widgetData.getString("location", "Wetter")
                val temp = widgetData.getFloat("temp", 0f)
                val condition = widgetData.getString("condition", "-")

                setTextViewText(R.id.widget_location, location)
                setTextViewText(R.id.widget_temp, "${temp.toInt()}°C")
                setTextViewText(R.id.widget_condition, condition)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
