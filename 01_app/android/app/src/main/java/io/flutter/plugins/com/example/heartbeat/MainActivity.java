package com.example.heartbeat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private PluxChannelHandler pluxHandler;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        pluxHandler = new PluxChannelHandler(flutterEngine, this);
    }
}
