package com.example.heartbeat;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class PluxChannelHandler {
    private static final String CHANNEL = "com.example.heartbeat/plux";
    private final PluxHandler pluxHandler;
    private final Activity activity;

    public PluxChannelHandler(FlutterEngine flutterEngine, Activity activity) {
        Log.d("PluxChannelHandler", "REGISTERING METHOD CHANNEL");

        this.activity = activity;
        pluxHandler = new PluxHandler(activity);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler((call, result) -> {
            switch (call.method) {

                case "testConnection": {
                    // Android 12+ needs runtime permissions for scan/connect
                    if (activity instanceof MainActivity) {
                        MainActivity ma = (MainActivity) activity;
                        if (!ma.hasPluxBluetoothPermissions()) {
                            ma.requestPluxBluetoothPermissions();
                            result.error(
                                    "PERMISSION_REQUIRED",
                                    "Bluetooth scan/connect permission required. Grant it, then tap again.",
                                    null
                            );
                            return;
                        }
                    }
                    pluxHandler.testConnection(result); // async: completes result on success/fail
                    break;
                }

                case "scanDevices": {
                    // Optional: later you can implement "return list to Flutter"
                    pluxHandler.scanDevices(result);
                    break;
                }

                default:
                    result.notImplemented();
            }
        });
    }
}