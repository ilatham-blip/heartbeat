package com.example.heartbeat;

import android.app.Activity;
import android.util.Log;

public class PluxHandler {
    private static final String TAG = "PluxHandler";
    private final Activity activity;


    public PluxHandler(Activity activity){
        this.activity = activity;
        Log.d(TAG, "PluxHandler initialized");
    }

    public void testConnection() {
        Log.d(TAG, "Connection Successful!!");
    }

    public void scanDevices() {
        Log.d(TAG, "Scanning devices...");
    }

}


//        // Initialise the Plux API
//        BiopluxCommunication bioplux = new BiopluxCommunicationFactory
//                ().getCommunication(Communication.BTH, getBaseContext(), new OnBiopluxDataAvailable(){
//            @Override
//            public void onBiopluxDataAvailable(BiopluxFrame biopluxFrame) {
//                Log.d(TAG, "BiopluxFrame: " + biopluxFrame.toString());
//            }
//        });
//
//        // Register the broadcast receiver
//        registerReceiver(mUpdateReceiver, updateIntentFilter());
//
//        bioplux.connect();