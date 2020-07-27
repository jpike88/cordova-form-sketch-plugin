package com.formpigeon.cordova.plugin.cordovaFormSketchPlugin;

import android.graphics.Bitmap;
import android.graphics.Matrix;

/**
 * Created by joshua on 15/02/2016.
 */
public class TextStamp {


    public float xLocation;
    public float yLocation;
    public String textValue;

    public TextStamp(float x, float y, String textValue){
        this.xLocation = x;
        this.yLocation = y;
        this.textValue = textValue;
    }


}
