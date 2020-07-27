package com.formpigeon.cordova.plugin.cordovaFormSketchPlugin;

import android.graphics.Bitmap;
import android.graphics.Matrix;

/**
 * Created by joshua on 15/02/2016.
 */
public class StampBitmap{

    public float xLocation;
    public float yLocation;
    public Bitmap bitmapData;

    public StampBitmap(float x, float y, Bitmap bd){
        this.xLocation = x;
        this.yLocation = y;
        this.bitmapData = getResizedBitmap(bd, 32, 32);
    }

    public Bitmap getResizedBitmap(Bitmap bm, int newWidth, int newHeight) {
        int width = bm.getWidth();
        int height = bm.getHeight();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        // CREATE A MATRIX FOR THE MANIPULATION
        Matrix matrix = new Matrix();
        // RESIZE THE BIT MAP
        matrix.postScale(scaleWidth, scaleHeight);

        // "RECREATE" THE NEW BITMAP
        Bitmap resizedBitmap = Bitmap.createBitmap(
                bm, 0, 0, width, height, matrix, false);

        return resizedBitmap;
    }
}
