package com.example.heartbeat;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    public static final int REQ_PLUX_BT = 7001;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        Log.d("MainActivity", "configureFlutterEngine CALLED");
        new PluxChannelHandler(flutterEngine, this);
    }

    public boolean hasPluxBluetoothPermissions() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true; // < Android 12
        return ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED;
    }

    public void requestPluxBluetoothPermissions() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return;
        ActivityCompat.requestPermissions(
                this,
                new String[]{Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT},
                REQ_PLUX_BT
        );
    }
}