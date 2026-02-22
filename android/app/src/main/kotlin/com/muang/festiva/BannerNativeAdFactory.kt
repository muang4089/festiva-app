package com.muang.festiva
 
import com.muang.festiva.R
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

import android.widget.Button
import android.widget.RatingBar
 
class BannerNativeAdFactory(val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {
 
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>? ): NativeAdView {
        val adView = LayoutInflater.from(context).inflate(R.layout.native_ad_banner, null) as NativeAdView

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
    

        // The headline and mediaContent are guaranteed to be in every NativeAd.
        (adView.headlineView as TextView).text = nativeAd?.headline?.replace(" ", "\u00A0");

        // These assets aren't guaranteed to be in every NativeAd, so it's important to
        // check before trying to display them.
        if (nativeAd?.body == null) {
          adView.bodyView?.visibility = View.INVISIBLE
        } else {
          adView.bodyView?.visibility = View.VISIBLE
          (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
          adView.callToActionView?.visibility = View.INVISIBLE
        } else {
          adView.callToActionView?.visibility = View.VISIBLE
          (adView.callToActionView as Button).text = "${nativeAd.callToAction} >"
        }

        if (nativeAd?.icon == null) {
          adView.iconView?.visibility = View.GONE
        } else {
          (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
          adView.iconView?.visibility = View.VISIBLE
        }

        // This method tells the Google Mobile Ads SDK that you have finished populating your
        // native ad view with this native ad.
        if (nativeAd != null) {
          adView.setNativeAd(nativeAd)
        }

        return adView
        }
}