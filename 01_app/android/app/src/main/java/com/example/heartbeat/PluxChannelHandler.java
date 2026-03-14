package com.example.heartbeat;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class PluxChannelHandler {
    private static final String METHOD_CHANNEL = "com.example.heartbeat/plux";
    private static final String EVENT_CHANNEL = "com.example.heartbeat/plux/data"; // NEW

    private final PluxHandler pluxHandler;
    private final Activity activity;

    // NEW: The funnel we pour data into
    public static EventChannel.EventSink dataSink;

    public PluxChannelHandler(FlutterEngine flutterEngine, Activity activity) {
        Log.d("PluxChannelHandler", "REGISTERING CHANNELS");

        this.activity = activity;
        pluxHandler = new PluxHandler(activity);

        // --- METHOD CHANNEL (For commands) ---
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                METHOD_CHANNEL
        ).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "testConnection": {
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
                    pluxHandler.testConnection(result);
                    break;
                }
                case "start": {
                    // Tell the PLUX SDK to start acquiring data!
                    pluxHandler.startAcquisition();
                    result.success(null);
                    break;
                }

                case "stop": {
                    // Tell the PLUX SDK to stop acquiring data and save battery!
                    pluxHandler.stopAcquisition();
                    result.success(null);
                    break;
                }
                case "disconnect": {
                    // This uses the stopAndDisconnect method already built into your PluxHandler!
                    pluxHandler.stopAndDisconnect(result);
                    break;
                }
                case "scanDevices": {
                    pluxHandler.scanDevices(result);
                    break;
                }
                default:
                    result.notImplemented();
            }
        });

        // --- NEW: EVENT CHANNEL (For streaming continuous data) ---
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        Log.d("PluxChannelHandler", "Flutter started listening to data stream!");
                        dataSink = events; // Open the funnel
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        Log.d("PluxChannelHandler", "Flutter stopped listening.");
                        dataSink = null; // Close the funnel
                    }
                });
    }


    // Accept BOTH variables now
    public static void sendDataToFlutter(double ppg, double ecg) {
        // THE MUTE GATE: If Flutter isn't listening, Android completely ignores the data!
        if (dataSink != null) {

            // We moved the print statement HERE!
            // Now it will ONLY print to the terminal during your 20-second recording.
            Log.d("PLUX_LIVE", ">>> A1: " + ppg + " | A2: " + ecg);

            new Handler(Looper.getMainLooper()).post(() -> {
                if (dataSink != null) {
                    dataSink.success(new double[]{ppg, ecg});
                }
            });
        }
    }
}