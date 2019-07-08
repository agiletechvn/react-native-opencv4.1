package com.reactlibrary;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.reactnativeopencvtutorial.R;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;


import org.opencv.core.Mat;
import org.opencv.core.Rect;
import org.opencv.android.Utils;
import org.opencv.core.MatOfRect;
import org.opencv.objdetect.CascadeClassifier;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class RNOpenCvLibraryModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private CascadeClassifier cascadeClassifier = null;

    public RNOpenCvLibraryModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNOpenCvLibrary";
    }

    @ReactMethod
    public void detect(String imageURL, Promise promise) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inDither = true;
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;

            URL url = new URL(imageURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap image = BitmapFactory.decodeStream(input, null, options);


            Mat matImage = new Mat();
            Utils.bitmapToMat(image, matImage);

            if(cascadeClassifier == null) {

                File cascadeDir = this.reactContext.getDir("cascade", Context.MODE_PRIVATE);
                File mCascadeFile = new File(cascadeDir, "haarcascade_frontalface_alt2.xml");

                // copy if not existed
                if (!mCascadeFile.exists()) {
                    InputStream is = this.reactContext.getResources().openRawResource(R.raw.haarcascade_frontalface_alt2);
                    FileOutputStream os = new FileOutputStream(mCascadeFile);
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = is.read(buffer)) != -1) {
                        os.write(buffer, 0, bytesRead);
                    }
                    is.close();
                    os.close();
                }

                // init one
                cascadeClassifier = new CascadeClassifier(mCascadeFile.getAbsolutePath());
            }


            // detect here
            MatOfRect rects = new MatOfRect();
            cascadeClassifier.detectMultiScale(matImage, rects);
            Rect[] faceRects = rects.toArray();
            WritableArray dataArray= Arguments.createArray();
            for(int i=0;i < faceRects.length; ++i){
                WritableMap dataMap = Arguments.createMap();
                dataMap.putInt("x", faceRects[i].x);
                dataMap.putInt("y", faceRects[i].y);
                dataMap.putInt("width", faceRects[i].width);
                dataMap.putInt("height", faceRects[i].height);

                dataArray.pushMap(dataMap);
            }

            promise.resolve(dataArray);

        } catch (Exception e) {
            promise.reject(e.getCause());
        }
    }
}
