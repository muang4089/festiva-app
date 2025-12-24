package com.ururu.festiva

import io.flutter.embedding.android.FlutterActivity

import com.ururu.festiva.ListTileNativeAdFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
 
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "adFactoryExample", ListTileNativeAdFactory(context)
        )
    }
 
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
 
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
    }
}
