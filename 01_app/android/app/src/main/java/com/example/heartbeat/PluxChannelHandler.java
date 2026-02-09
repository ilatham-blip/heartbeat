package com.example.heartbeat;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class PluxChannelHandler {
    private static final String CHANNEL = "com.example.heartbeat/plux";
    private final PluxHandler pluxHandler;

    public PluxChannelHandler(FlutterEngine flutterEngine, Activity activity){
        Log.d("PluxChannelHandler", "REGISTERING METHOD CHANNEL");

        pluxHandler = new PluxHandler(activity);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        ).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "testConnection":
                            pluxHandler.testConnection();
                            result.success("Java connection successful!");
                            break;

                        case "scanDevices":
                            pluxHandler.scanDevices();
                            result.success(null);
                            break;

                        default:
                            result.notImplemented();
                    }
                }
        );

    }
}