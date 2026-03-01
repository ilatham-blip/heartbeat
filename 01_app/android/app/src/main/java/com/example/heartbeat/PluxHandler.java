package com.example.heartbeat;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.core.app.ActivityCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

// PLUX API (1.5.2)
import info.plux.api.bioplux.BiopluxCommunication;
import info.plux.api.bioplux.BiopluxCommunicationFactory;
import info.plux.api.bioplux.OnBiopluxError;
import info.plux.api.enums.PLUXDevices;
import info.plux.api.enums.TypeOfCommunication;

public class PluxHandler {
    private static final String TAG = "PluxHandler";

    // Your device MAC (you can override by calling connectToMac from Flutter)
    private static final String DEFAULT_MAC = "98:D3:51:FE:88:35";

    private final Activity activity;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private BluetoothAdapter btAdapter;

    // For scan results (dedupe by MAC, preserve insertion order)
    private final LinkedHashMap<String, String> found = new LinkedHashMap<>();
    private boolean isScanning = false;

    private MethodChannel.Result pendingScanResult;
    private MethodChannel.Result pendingConnectResult;

    private BiopluxCommunication bioplux;

    public PluxHandler(Activity activity) {
        this.activity = activity;
        this.btAdapter = BluetoothAdapter.getDefaultAdapter();
        Log.d(TAG, "PluxHandler initialized. BT adapter=" + (btAdapter != null));
    }

    /**
     * Sample-like scan:
     * - starts Android Bluetooth discovery
     * - collects devices for a few seconds
     * - returns list to Flutter: [{name: "...", mac: "..."}]
     */
    public void scanDevices(MethodChannel.Result result) {
        if (pendingScanResult != null) {
            result.error("BUSY", "Already scanning. Try again in a moment.", null);
            return;
        }

        if (btAdapter == null) {
            result.error("NO_BT", "Bluetooth adapter not available on this device.", null);
            return;
        }

        // Permissions check (won't stop compile; helps runtime)
        if (!hasBtScanPermission()) {
            result.error(
                    "NO_PERMISSION",
                    "Missing Bluetooth scan permission. Add BLUETOOTH_SCAN/BLUETOOTH_CONNECT (Android 12+) and request at runtime.",
                    null
            );
            return;
        }

        pendingScanResult = result;
        found.clear();

        // Register receiver
        try {
            activity.registerReceiver(btReceiver, makeBtIntentFilter());
        } catch (Exception e) {
            Log.w(TAG, "Receiver register failed (maybe already registered): " + e.getMessage());
        }

        // Stop any ongoing discovery and start fresh
        try {
            if (btAdapter.isDiscovering()) btAdapter.cancelDiscovery();
        } catch (Exception ignored) {}

        isScanning = true;
        boolean started = btAdapter.startDiscovery();
        Log.d(TAG, "Bluetooth discovery started=" + started);

        // Auto-finish scan after 6 seconds (tweak if needed)
        mainHandler.postDelayed(this::finishScan, 6000);
    }

    /**
     * Connect to a MAC address (use after scan or use default).
     * Returns success string to Flutter; errors otherwise.
     */
    public void connectToMac(String mac, MethodChannel.Result result) {
        if (pendingConnectResult != null) {
            result.error("BUSY", "Already connecting. Try again in a moment.", null);
            return;
        }

        if (btAdapter == null) {
            result.error("NO_BT", "Bluetooth adapter not available on this device.", null);
            return;
        }

        if (!hasBtConnectPermission()) {
            result.error(
                    "NO_PERMISSION",
                    "Missing Bluetooth connect permission. Add BLUETOOTH_CONNECT (Android 12+) and request at runtime.",
                    null
            );
            return;
        }

        final String targetMac = (mac == null || mac.trim().isEmpty()) ? DEFAULT_MAC : mac.trim();
        pendingConnectResult = result;

        // Best effort: stop discovery before connecting
        try {
            if (btAdapter.isDiscovering()) btAdapter.cancelDiscovery();
        } catch (Exception ignored) {}

        Log.d(TAG, "Connecting to PLUX device MAC=" + targetMac);

        // Create PLUX comm object
        try {
            bioplux = new BiopluxCommunicationFactory()
                    .getCommunication(
                            PLUXDevices.BIOPLUX,                 // safest default for HeartBIT/BioPlux family
                            TypeOfCommunication.BTH,             // Classic Bluetooth (you used BTH/BTH in earlier code)
                            activity.getBaseContext(),
                            pluxErrorCallback
                    );
        } catch (Exception e) {
            failConnect("INIT_FAIL", "Failed to init PLUX comm: " + e.getMessage());
            return;
        }

        // Call connect (in 1.5.2 this is void, not boolean)
        try {
            bioplux.connect(targetMac);
        } catch (Exception e) {
            failConnect("CONNECT_FAIL", "connect() threw: " + e.getMessage());
            return;
        }

        // Since we’re not wiring full “device ready” callbacks yet, we just return success optimistically
        // after a short delay if no error callback fired.
        mainHandler.postDelayed(() -> {
            if (pendingConnectResult != null) {
                MethodChannel.Result r = pendingConnectResult;
                pendingConnectResult = null;
                r.success("Connect called for " + targetMac + ". Check logs for further status.");
            }
        }, 1200);
    }

    /** Convenience: button “Test” calls connect to your known MAC. */
    public void testConnection(MethodChannel.Result result) {
        connectToMac(DEFAULT_MAC, result);
    }

    // -----------------------------
    // Bluetooth receiver (scan)
    // -----------------------------
    private final BroadcastReceiver btReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null || intent.getAction() == null) return;

            String action = intent.getAction();

            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device == null) return;

                String mac = device.getAddress();
                String name = device.getName();
                if (name == null) name = "(unknown)";

                // Save / dedupe
                if (!found.containsKey(mac)) {
                    found.put(mac, name);
                    Log.d(TAG, "Found: " + name + " [" + mac + "]");
                }
            }

            if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                Log.d(TAG, "Discovery finished event");
                finishScan();
            }
        }
    };

    private void finishScan() {
        if (!isScanning) return;
        isScanning = false;

        try {
            if (btAdapter != null && btAdapter.isDiscovering()) btAdapter.cancelDiscovery();
        } catch (Exception ignored) {}

        try {
            activity.unregisterReceiver(btReceiver);
        } catch (Exception ignored) {}

        if (pendingScanResult == null) return;

        List<Map<String, String>> out = new ArrayList<>();
        for (Map.Entry<String, String> e : found.entrySet()) {
            HashMap<String, String> item = new HashMap<>();
            item.put("mac", e.getKey());
            item.put("name", e.getValue());
            out.add(item);
        }

        MethodChannel.Result r = pendingScanResult;
        pendingScanResult = null;

        Log.d(TAG, "Scan complete. Devices=" + out.size());
        r.success(out);
    }

    private IntentFilter makeBtIntentFilter() {
        IntentFilter f = new IntentFilter();
        f.addAction(BluetoothDevice.ACTION_FOUND);
        f.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        return f;
    }

    // -----------------------------
    // PLUX error callback (1.5.2)
    // -----------------------------
    private final OnBiopluxError pluxErrorCallback = new OnBiopluxError() {
        @Override
        public void onBiopluxError(int errorType, String message) {
            Log.e(TAG, "PLUX error: type=" + errorType + " msg=" + message);
            failConnect("PLUX_ERROR", "type=" + errorType + " msg=" + message);
        }
    };

    private void failConnect(String code, String msg) {
        if (pendingConnectResult != null) {
            MethodChannel.Result r = pendingConnectResult;
            pendingConnectResult = null;
            r.error(code, msg, null);
        }
    }

    // -----------------------------
    // Permissions helpers
    // -----------------------------
    private boolean hasBtScanPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            // Pre-Android 12: location permission is often needed for discovery results
            return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION)
                    == PackageManager.PERMISSION_GRANTED
                    || ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_COARSE_LOCATION)
                    == PackageManager.PERMISSION_GRANTED;
        }
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_SCAN)
                == PackageManager.PERMISSION_GRANTED;
    }

    private boolean hasBtConnectPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true;
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.BLUETOOTH_CONNECT)
                == PackageManager.PERMISSION_GRANTED;
    }
}