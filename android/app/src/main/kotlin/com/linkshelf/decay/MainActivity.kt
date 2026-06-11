package com.linkshelf.decay

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onPause() {
        super.onPause()
        intent?.let {
            if (it.action?.startsWith("android.intent.action.SEND") == true) {
                it.action = Intent.ACTION_MAIN
            }
        }
    }
}
