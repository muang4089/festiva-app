package com.muang.festiva

import io.flutter.embedding.android.FlutterActivity

import com.muang.festiva.ListTileNativeAdFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
 
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTileAd", ListTileNativeAdFactory(context)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "bannerAd", BannerNativeAdFactory(context)
        )
        
    }
 
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
 
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTileAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "bannerAd")
    }
}
