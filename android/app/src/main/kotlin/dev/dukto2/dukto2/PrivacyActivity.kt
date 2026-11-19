package dev.dukto2.dukto2

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.FrameLayout
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast

/** No Flutter, scanner, discovery, permissions or WebView before explicit consent. */
class PrivacyActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (PrivacyConsent.accepted(this)) {
            openApp()
            return
        }
        showPrivacyNotice()
    }

    private fun dp(value: Int) = (value * resources.displayMetrics.density).toInt()

    private fun showPrivacyNotice() {
        val dark = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES
        val surface = if (dark) Color.rgb(28, 30, 36) else Color.WHITE
        val ink = if (dark) Color.rgb(236, 238, 244) else Color.rgb(28, 34, 46)
        val muted = if (dark) Color.rgb(190, 196, 210) else Color.rgb(91, 100, 117)
        val accent = if (dark) Color.rgb(157, 181, 255) else Color.rgb(49, 91, 231)
        fun label(value: String, size: Float, color: Int = ink) = TextView(this).apply {
            text = value
            textSize = size
            setTextColor(color)
            setPadding(0, dp(8), 0, dp(8))
        }
        // A presentation-only home surface: never instantiate Flutter, read saved
        // devices/history, or register plugins just to decorate the consent screen.
        val home = LinearLayout(this).apply {
            tag = "privacy-home-preview"
            orientation = LinearLayout.VERTICAL
            setPadding(dp(24), dp(24), dp(24), dp(24))
            setBackgroundColor(surface)
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
            isFocusable = false
        }
        val header = LinearLayout(this).apply { gravity = Gravity.CENTER_VERTICAL }
        header.addView(android.widget.ImageView(this).apply {
            setImageResource(R.mipmap.ic_launcher)
        }, LinearLayout.LayoutParams(dp(40), dp(40)))
        header.addView(label("Dukto2", 28f).apply {
            setTypeface(typeface, Typeface.BOLD)
            setPadding(dp(12), 0, 0, 0)
        })
        home.addView(header)
        home.addView(label(getString(R.string.nearbyDevices).replace("{arg0}", "0"), 16f, muted),
            LinearLayout.LayoutParams(-1, -2).apply { topMargin = dp(40) })
        val empty = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
        }
        empty.addView(label(getString(R.string.noNearbyDevices), 21f).apply {
            gravity = Gravity.CENTER
            setTypeface(typeface, Typeface.BOLD)
        })
        empty.addView(label(getString(R.string.qrInstructions), 16f, muted).apply { gravity = Gravity.CENTER })
        home.addView(empty, LinearLayout.LayoutParams(-1, 0, 1f))
        val connections = LinearLayout(this).apply { gravity = Gravity.CENTER }
        for (id in listOf(R.string.scanQr, R.string.manualConnection)) {
            connections.addView(label(getString(id), 14f, muted).apply { gravity = Gravity.CENTER },
                LinearLayout.LayoutParams(0, -2, 1f))
        }
        home.addView(connections)
        home.addView(View(this).apply { setBackgroundColor(muted); alpha = 0.2f },
            LinearLayout.LayoutParams(-1, dp(1)).apply { topMargin = dp(32); bottomMargin = dp(24) })
        home.addView(label(getString(R.string.recentTransfers), 18f).apply { setTypeface(typeface, Typeface.BOLD) })
        home.addView(label(getString(R.string.allDevices), 16f, muted))

        val card = LinearLayout(this).apply {
            tag = "privacy-dialog"
            orientation = LinearLayout.VERTICAL
            setPadding(dp(24), dp(20), dp(24), dp(16))
            layoutDirection = View.LAYOUT_DIRECTION_LOCALE
            background = GradientDrawable().apply { setColor(surface); cornerRadius = dp(24).toFloat() }
            elevation = dp(12).toFloat()
        }
        card.addView(label(getString(R.string.privacyWelcomeTitle), 23f).apply {
            setTypeface(typeface, Typeface.BOLD)
            accessibilityHeadingCompat()
        })
        card.addView(ScrollView(this).apply {
            tag = "privacy-summary-scroll"
            isFillViewport = false
            addView(label(getString(R.string.privacyWelcomeBody), 16f, muted).apply {
                setLineSpacing(dp(3).toFloat(), 1.1f)
            })
        }, LinearLayout.LayoutParams(-1, 0, 1f))
        fun action(id: Int, key: String, primary: Boolean = false, click: (View) -> Unit) = Button(this).apply {
            tag = key
            setText(id)
            isAllCaps = false
            textSize = 16f
            minHeight = dp(48)
            setTextColor(if (primary) (if (dark) Color.rgb(17, 35, 82) else Color.WHITE) else accent)
            backgroundTintList = android.content.res.ColorStateList.valueOf(if (primary) accent else Color.TRANSPARENT)
            setOnClickListener(click)
        }
        card.addView(action(R.string.privacyReadPolicy, "privacy-read-policy") {
            try {
                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(PrivacyConsent.POLICY_URL)))
            } catch (_: ActivityNotFoundException) {
                Toast.makeText(this, R.string.privacyPolicyUnavailable, Toast.LENGTH_LONG).show()
            }
        }, LinearLayout.LayoutParams(-1, -2))
        card.addView(action(R.string.privacyAccept, "privacy-accept", true) { button ->
            button.isEnabled = false
            if (PrivacyConsent.accept(this)) {
                openApp()
            } else {
                button.isEnabled = true
                Toast.makeText(this, R.string.privacySaveFailed, Toast.LENGTH_LONG).show()
            }
        }, LinearLayout.LayoutParams(-1, -2))
        card.addView(action(R.string.privacyDecline, "privacy-decline") { finishAndRemoveTask() },
            LinearLayout.LayoutParams(-1, -2))
        // Reflow on rotation and large system fonts. Only the summary scrolls;
        // policy and both decision buttons stay reachable on short screens.
        val root = object : FrameLayout(this) {
            override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
                val w = View.MeasureSpec.getSize(widthMeasureSpec)
                val h = View.MeasureSpec.getSize(heightMeasureSpec)
                val params = card.layoutParams as LayoutParams
                params.width = minOf((w - dp(32)).coerceAtLeast(1), dp(480))
                params.height = minOf((h - dp(32)).coerceAtLeast(1), dp(680))
                super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            }
        }
        root.addView(home, FrameLayout.LayoutParams(-1, -1))
        root.addView(View(this).apply {
            tag = "privacy-scrim"
            setBackgroundColor(Color.argb(145, 0, 0, 0))
            isClickable = true
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }, FrameLayout.LayoutParams(-1, -1))
        root.addView(card, FrameLayout.LayoutParams(-1, -1, Gravity.CENTER))
        setContentView(root)
    }

    private fun TextView.accessibilityHeadingCompat() {
        if (android.os.Build.VERSION.SDK_INT >= 28) isAccessibilityHeading = true
    }

    private fun openApp() {
        startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP))
        finish()
    }
}
