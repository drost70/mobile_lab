package com.example.my_project

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    private val ACTION_USB_PERMISSION = "com.example.my_project.USB_PERMISSION"
    private lateinit var usbManager: UsbManager
    private lateinit var permissionIntent: PendingIntent

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == ACTION_USB_PERMISSION) {
                synchronized(this) {
                    val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        device?.let {
                            println("Дозвіл на USB пристрій надано: $device")
                        }
                    } else {
                        println("Дозвіл на USB пристрій відмовлено")
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        permissionIntent = PendingIntent.getBroadcast(
          this,
          0,
          Intent(ACTION_USB_PERMISSION),
          PendingIntent.FLAG_IMMUTABLE // або FLAG_MUTABLE,
        )
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        registerReceiver(usbReceiver, filter)

        // Запит дозволу для всіх підключених USB-пристроїв
        for (device in usbManager.deviceList.values) {
            if (!usbManager.hasPermission(device)) {
                usbManager.requestPermission(device, permissionIntent)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(usbReceiver)
    }
}
