package com.example.heartbeat;

import info.plux.api.bitalino.BITalinoFrame;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Parcelable;
import android.util.Log;

import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel;

// Core PLUX Imports
import info.plux.api.bitalino.BITalinoCommunication;
import info.plux.api.bitalino.BITalinoCommunicationFactory;
import info.plux.api.enums.TypeOfCommunication;
import info.plux.api.interfaces.OnDataAvailable;

public class PluxHandler {
    private final Activity activity;

    // We are strictly using the dedicated BITalino object now
    private BITalinoCommunication bitalino;

    private MethodChannel.Result pendingResult;
    private boolean isConnecting = false;

    private static final String MAC_ADDRESS = "98:D3:51:FE:88:35";

    public PluxHandler(Activity activity) {
        this.activity = activity;
    }

    public void testConnection(MethodChannel.Result result) {
        if (isConnecting) return;

        isConnecting = true;
        this.pendingResult = result;

        try {
            // Initialize using the pure BITalino factory
            bitalino = new BITalinoCommunicationFactory().getCommunication(
                    TypeOfCommunication.BTH,
                    activity,
                    onDataAvailable
            );

            IntentFilter filter = new IntentFilter();
            filter.addAction("info.plux.api.bioplux.ACTION_STATE_CHANGED");
            filter.addAction("info.plux.api.bitalino.ACTION_STATE_CHANGED");
            filter.addAction("info.plux.api.ACTION_STATE_CHANGED");
            filter.addAction("bitalino.intent.action.STATE_CHANGED");

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.registerReceiver(pluxReceiver, filter, Context.RECEIVER_EXPORTED);
            } else {
                activity.registerReceiver(pluxReceiver, filter);
            }

            Log.d("PLUX", "Connecting to BITalino: " + MAC_ADDRESS);
            bitalino.connect(MAC_ADDRESS);

            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                if (isConnecting) {
                    Log.e("PLUX", "Handshake timed out. Unlocking.");
                    isConnecting = false;
                }
            }, 8000);

        } catch (Exception e) {
            isConnecting = false;
            if(result != null) result.error("ERR", e.getMessage(), null);
        }
    }

    private final BroadcastReceiver pluxReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getExtras() != null) {
                for (String key : intent.getExtras().keySet()) {
                    String valStr = String.valueOf(intent.getExtras().get(key));

                    if (valStr.equals("3") || valStr.toUpperCase().contains("CONNECTED")) {
                        Log.d("PLUX", "SUCCESS! State is CONNECTED.");

                        // We removed bitalino.start() from here!
                        // Now it just tells Flutter it successfully connected and waits silently.
                        isConnecting = false;
                        if (pendingResult != null) {
                            pendingResult.success("Connected");
                            pendingResult = null;
                        }
                        return;
                    } else if (valStr.equals("0") || valStr.toUpperCase().contains("DISCONNECTED")) {
                        isConnecting = false;
                    }
                }
            }
        }
    };

    // Using the unified OnDataAvailable interface we know the compiler accepts
    private final OnDataAvailable onDataAvailable = new OnDataAvailable() {
        @Override
        public void onDataAvailable(Parcelable data) {
            if (data instanceof BITalinoFrame) {
                BITalinoFrame frame = (BITalinoFrame) data;

                // The array we sent was {0, 1, 2, 3, 4, 5}.
                // Index 0 is A1, Index 1 is A2.
                int a1Value = frame.getAnalog(0);
                int a2Value = frame.getAnalog(1);

                // This will now only print when the hardware is explicitly told to start!
                Log.d("PLUX", ">>> A1: " + a1Value + " | A2: " + a2Value);
                PluxChannelHandler.sendDataToFlutter(a1Value, a2Value);
            }
        }

        @Override
        public void onDataAvailable(String id, int seq, int[] analog, int digital) {}

        @Override
        public void onDataLost(String id, int n) {}
    };

    // ─── NEW HARDWARE SWITCHES (Step 3) ──────────────────────────────────

    public void startAcquisition() {
        try {
            if (bitalino != null) {
                Log.d("PLUX", "Hardware switch: ON. Starting stream...");
                // The exact start command you had earlier
                bitalino.start(100, new int[]{0, 1, 2, 3, 4, 5});
            }
        } catch (Exception e) {
            Log.e("PLUX", "Error starting hardware: " + e.getMessage());
        }
    }

    public void stopAcquisition() {
        try {
            if (bitalino != null) {
                Log.d("PLUX", "Hardware switch: OFF. Stopping stream to save battery.");
                bitalino.stop();
            }
        } catch (Exception e) {
            Log.e("PLUX", "Error stopping hardware: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────

    public void scanDevices(MethodChannel.Result r) { r.success(new ArrayList<>()); }

    public void stopAndDisconnect(MethodChannel.Result r) {
        isConnecting = false;

        if (bitalino != null) {
            // 1. Safely stop streaming. If it's already stopped, it throws an error. We catch it quietly!
            try {
                bitalino.stop();
            } catch (Exception e) {
                Log.d("PLUX", "Stream was already stopped.");
            }

            // 2. THIS IS THE FIX: Disconnect is now protected in its own block so it NEVER gets skipped!
            try {
                bitalino.disconnect();
                Log.d("PLUX", "Hardware Bluetooth successfully disconnected.");
            } catch (Exception e) {
                Log.e("PLUX", "Error hanging up Bluetooth", e);
            }

            bitalino = null; // Destroy the object completely
        }

        // 3. Clean up the listener so they don't stack up
        try {
            activity.unregisterReceiver(pluxReceiver);
        } catch (Exception ignored) {}

        if(r != null) r.success(null);
    }
}