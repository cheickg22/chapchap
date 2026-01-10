package package name here

import package name here.ChatHeadService
import android.content.Context
import android.content.Intent
import android.graphics.Point
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import kotlin.math.ceil
import kotlin.random.Random
import android.os.Bundle
import androidx.core.view.WindowCompat

class MainActivity : FlutterFragmentActivity() {
    private lateinit var channel: MethodChannel
    private var density: Float = 0.0f
    private var screenHeightLP: Double? = 0.0
    private var navigationBarHeight: Double = 0.0
    private var screenWidth: Int = 0
    private var chatHeadIcon: String? = ""
    private var notificationIcon: String? = ""
    private var notificationTitle: String? = ""
    private var notificationBody: String? = ""
    private var notificationCircleHexColor: Long? = 0
    private var serviceStarted: Boolean = false

    private val ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE = 1237

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "package name here")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initService" -> handleInitService(call, result)
                "startService" -> handleStartService(call, result)
                "checkPermission" -> result.success(checkPermission())
                "askPermission" -> {
                    askPermission()
                    Toast.makeText(this, "Allow display over other apps permission", Toast.LENGTH_SHORT).show()
                    result.success(true)
                }
                "stopService" -> handleStopService(result)
                "clearServiceNotification" -> {
                    cancelNotification()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun cancelNotification() {
        NotificationManagerCompat.from(this).cancel(ChatHeadService.NOTIFICATION_ID)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun checkPermission(): Boolean {
        return Settings.canDrawOverlays(this)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun askPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE)
            return true
        }
        return false
    }

    private fun stopChatHeadService() {
        try {
            stopService(Intent(this, ChatHeadService::class.java))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startChatHeadService() {
        Intent(this, ChatHeadService::class.java).apply {
            putExtra("height", getRealScreenHeight())
            putExtra("width", screenWidth.toDouble())
            putExtra("density", density.toDouble())
            putExtra("navigationBarHeight", navigationBarHeight)
            putExtra("chatHeadIcon", chatHeadIcon)
            putExtra("notificationIcon", notificationIcon)
            putExtra("notificationTitle", notificationTitle)
            putExtra("notificationBody", notificationBody)
            putExtra("notificationCircleHexColor", notificationCircleHexColor)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //     // startForegroundService(this)
            // } else {
                startService(this)
            // }
        }
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private fun getRealScreenHeight(): Double {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val point = Point()
        windowManager.defaultDisplay.getRealSize(point)
        return point.y.toDouble()
    }

    private fun handleInitService(call: MethodCall, result: Result) {
        density = call.argument<Double>("density")?.toFloat() ?: 0.0f
        screenHeightLP = call.argument<Double>("screenHeight")
        navigationBarHeight = call.argument<Double>("navigationBarHeight") ?: 0.0
        screenWidth = call.argument<Int>("screenWidth") ?: 0
        chatHeadIcon = call.argument<String>("chatHeadIcon")
        notificationIcon = call.argument<String>("notificationIcon")
        notificationTitle = call.argument<String>("notificationTitle")
        notificationBody = call.argument<String>("notificationBody")
        notificationCircleHexColor = call.argument<Long>("notificationCircleHexColor") ?: 0

        result.success(true)
    }

    private fun handleStartService(call: MethodCall, result: Result) {
        if (!serviceStarted) {
            startChatHeadService()
            serviceStarted = true
            result.success(true)
        } else {
            // Optionally restart or just report it's already running
            result.success("Service already running")
        }
    }

    private fun handleStopService(result: Result) {
        
        if (serviceStarted) {
            stopChatHeadService()
            serviceStarted = false
            result.success(true)
        } else {
            // Optionally restart or just report it's already running
            result.success("Service already running")
        }
    }

}