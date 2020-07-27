/**
 * CanvasView.java
 *
 * Copyright (c) 2014 Tomohiro IKEDA (Korilakkuma)
 * Released under the MIT license
 */

package com.formpigeon.sketch;

import java.io.ByteArrayOutputStream;
import java.util.List;
import java.util.ArrayList;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.graphics.PorterDuffXfermode;
import android.graphics.PorterDuff;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.util.AttributeSet;
import android.view.View;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
// import android.util.Log;
// import android.widget.Toast;


/**
 * This class defines fields and methods for drawing.
 */
public class CanvasView extends View {

    public double w = 0;
    public double h = 0;

    private static float MIN_ZOOM = 1f;
    private static float MAX_ZOOM = 5f;
    public Bitmap stamp = null;
    private float scaleFactor = 1.f;
    private ScaleGestureDetector detector;
    private boolean drawGridEnabled = true;


    private class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {
        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            scaleFactor *= detector.getScaleFactor();
            scaleFactor = Math.max(MIN_ZOOM, Math.min(scaleFactor, MAX_ZOOM));
            invalidate();
            return true;
        }
    }

    // Enumeration for Mode
    public enum Mode {
        DRAW,
        TEXT,
        STAMP,
        ERASER;
    }

    // Enumeration for Drawer
    public enum Drawer {
        PEN,
        LINE,
        RECTANGLE,
        CIRCLE,
        ELLIPSE
    }



    private Context context = null;
    public Canvas canvas   = null;
    private Bitmap bitmap   = null;

    private List<Object>  objectLists  = new ArrayList<Object>();
    private List<Paint> paintLists = new ArrayList<Paint>();

    // for Eraser
    private int baseColor = Color.WHITE;



    public int gridWidth = 32;


    private float normaliseToGrid(float input){

        if (input < (input - (input % gridWidth)) + (gridWidth/2)){

            input = (input - (input % gridWidth));

        } else if (input >= (input - (input % gridWidth)) + (gridWidth/2)){

            input = (input - (input % gridWidth)) + gridWidth;

        }

        return input;
    }


    // for Undo, Redo
    private int historyPointer = 0;

    // Flags
    private Mode mode      = Mode.DRAW;
    private Drawer drawer  = Drawer.LINE;
    private boolean isDown = false;

    // for Paint
    private Paint.Style paintStyle = Paint.Style.STROKE;
    private int paintStrokeColor   = Color.BLACK;
    private int paintFillColor     = Color.BLACK;
    private float paintStrokeWidth = 3F;
    private int opacity            = 255;
    private float blur             = 0F;
    private Paint.Cap lineCap      = Paint.Cap.ROUND;

    // for Text
    private String text           = "";
    private Typeface fontFamily   = Typeface.DEFAULT;
    private float fontSize        = 32F;
    private Paint.Align textAlign = Paint.Align.RIGHT;  // fixed
    private Paint textPaint       = new Paint();
    private float textX           = 0F;
    private float textY           = 0F;

    // for Drawer
    private float startX   = 0F;
    private float startY   = 0F;
    private float controlX = 0F;
    private float controlY = 0F;

    /**
     * Copy Constructor
     *
     * @param context
     * @param attrs
     * @param defStyle
     */
    public CanvasView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        detector = new ScaleGestureDetector(getContext(), new ScaleListener());

        this.setup(context);
    }

    /**
     * Copy Constructor
     *
     * @param context
     * @param attrs
     */
    public CanvasView(Context context, AttributeSet attrs) {
        super(context, attrs);
        detector = new ScaleGestureDetector(getContext(), new ScaleListener());

        this.setup(context);
    }

    /**
     * Copy Constructor
     *
     * @param context
     */
    public CanvasView(Context context) {
        super(context);
        detector = new ScaleGestureDetector(getContext(), new ScaleListener());

        this.setup(context);
    }

    /**
     * Common initialization.
     *
     * @param context
     */
    private void setup(Context context) {
        this.context = context;

        this.objectLists.add(new Path());
        this.paintLists.add(this.createPaint());
        this.historyPointer++;

        this.textPaint.setARGB(0, 255, 255, 255);
    }

    /**
     * This method creates the instance of Paint.
     * In addition, this method sets styles for Paint.
     *
     * @return paint This is returned as the instance of Paint
     */
    private Paint createPaint() {
        Paint paint = new Paint();

        paint.setAntiAlias(true);
        paint.setStyle(this.paintStyle);
        paint.setStrokeWidth(this.paintStrokeWidth);
        paint.setStrokeCap(this.lineCap);
        paint.setStrokeJoin(Paint.Join.MITER);  // fixed

        // for Text
        if (this.mode == Mode.TEXT) {
            paint.setTypeface(this.fontFamily);
            paint.setTextSize(this.fontSize);
            paint.setTextAlign(this.textAlign);
            paint.setStrokeWidth(0F);
        }

        if (this.mode == Mode.ERASER) {
            // Eraser
            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.CLEAR));
            paint.setARGB(0, 0, 0, 0);

            // paint.setColor(this.baseColor);
            // paint.setShadowLayer(this.blur, 0F, 0F, this.baseColor);
        } else {
            // Otherwise
            paint.setColor(this.paintStrokeColor);
            paint.setShadowLayer(this.blur, 0F, 0F, this.paintStrokeColor);
            paint.setAlpha(this.opacity);
        }

        return paint;
    }

    /**
     * This method initialize Path.
     * Namely, this method creates the instance of Path,
     * and moves current position.
     *
     * @param event This is argument of onTouchEvent method
     * @return path This is returned as the instance of Path
     */
    private Path createPath(MotionEvent event) {
        Path path = new Path();

        // Save for ACTION_MOVE
        this.startX = normaliseToGrid(event.getX());
        this.startY = normaliseToGrid(event.getY());

        path.moveTo(this.startX, this.startY);

        return path;
    }



    private StampBitmap createStamp(MotionEvent event){

        return (new StampBitmap(normaliseToGrid(event.getX() - (event.getX() % this.gridWidth)), normaliseToGrid(event.getY() - (event.getY() % this.gridWidth)), this.stamp));


    }

    private TextStamp createTextStamp(MotionEvent event){

        return (new TextStamp(normaliseToGrid(event.getX()), normaliseToGrid(event.getY()), this.text));


    }


    public StartingBitmap createStartingImage(Bitmap b){

        return (new StartingBitmap(b));


    }



    /**
     * This method updates the lists for the instance of Path and Paint.
     * "Undo" and "Redo" are enabled by this method.
     *
     * @param object the instance of Path
     * @param paint the instance of Paint
     */
    public void updateHistory(Object drawable) {
        if (this.historyPointer == this.objectLists.size()) {
            this.objectLists.add(drawable);
            this.paintLists.add(this.createPaint());
            this.historyPointer++;
        } else {
            // On the way of Undo or Redo
            this.objectLists.set(this.historyPointer, drawable);
            this.paintLists.set(this.historyPointer, this.createPaint());
            this.historyPointer++;

            for (int i = this.historyPointer, size = this.paintLists.size(); i < size; i++) {
                this.objectLists.remove(this.historyPointer);
                this.paintLists.remove(this.historyPointer);
            }
        }
    }


    private void updateTextHistory() {
//        if (this.historyPointer == this.pathLists.size()) {
//           // this.pathLists.add(path);
//            this.paintLists.add(this.createPaint());
//            this.historyPointer++;
//        } else {
//            // On the way of Undo or Redo
//            //this.pathLists.set(this.historyPointer, "text");
//            this.paintLists.set(this.historyPointer, this.createPaint());
//            this.historyPointer++;
//
//            for (int i = this.historyPointer, size = this.paintLists.size(); i < size; i++) {
//                this.pathLists.remove(this.historyPointer);
//                this.paintLists.remove(this.historyPointer);
//            }
//        }
    }


    /**
     * This method gets the instance of Path that pointer indicates.
     *
     * @return the instance of Path
     */
    private Object getCurrentObject() {
        return this.objectLists.get(this.historyPointer - 1);
    }

    /**
     * This method defines processes on MotionEvent.ACTION_DOWN
     *
     * @param event This is argument of onTouchEvent method
     */
    private void onActionDown(MotionEvent event) {
        switch (this.mode) {
            case STAMP :
                // draw the stamp.
                //
                // draw stamp at coordinates
                this.updateHistory(this.createStamp(event));
                // list stamp

                // list sta

                //this.stamp;
                break;
            case DRAW   :
            case ERASER :

                this.updateHistory(this.createPath(event));
                this.isDown = true;


                break;
            case TEXT   :
                this.startX = normaliseToGrid(event.getX());
                this.startY = normaliseToGrid(event.getY());
                this.updateHistory(this.createTextStamp(event));
                //this.updateTextHistory(this.createPath(event));
                break;
            default :
                break;
        }
    }

    /**
     * This method defines processes on MotionEvent.ACTION_MOVE
     *
     * @param event This is argument of onTouchEvent method
     */
    private void onActionMove(MotionEvent event) {
        float x = normaliseToGrid(event.getX());
        float y = normaliseToGrid(event.getY());

        switch (this.mode) {
            case DRAW   :
            case ERASER :

                if (!isDown) {
                    return;
                }

                Path path = (Path)this.getCurrentObject();

                switch (this.drawer) {
                    case PEN :
                        path.lineTo(x, y);
                        break;
                    case LINE :
                        path.reset();
                        path.moveTo(this.startX, this.startY);
                        path.lineTo(x, y);
                        break;
                    case RECTANGLE :
                        path.reset();
                        path.addRect(this.startX, this.startY, x, y, Path.Direction.CCW);
                        break;
                    case CIRCLE :
                        double distanceX = Math.abs((double)(this.startX - x));
                        double distanceY = Math.abs((double)(this.startX - y));
                        double radius    = Math.sqrt(Math.pow(distanceX, 2.0) + Math.pow(distanceY, 2.0));

                        path.reset();
                        path.addCircle(this.startX, this.startY, (float)radius, Path.Direction.CCW);
                        break;
                    case ELLIPSE :
                        RectF rect = new RectF(this.startX, this.startY, x, y);

                        path.reset();
                        path.addOval(rect, Path.Direction.CCW);
                        break;
                    default :
                        break;
                }


                break;
            case TEXT :
                break;
            default :
                break;
        }
    }

    /**
     * This method defines processes on MotionEvent.ACTION_DOWN
     *
     * @param event This is argument of onTouchEvent method
     */
    private void onActionUp(MotionEvent event) {

        if (isDown) {
            this.startX = 0F;
            this.startY = 0F;
            this.isDown = false;
        }
    }

    private Paint lines = new Paint();

    public void drawGrid (Canvas canvas) {


        lines.setColor(Color.LTGRAY);

        if (this.bitmap != null) {
            canvas.drawBitmap(this.bitmap, 0F, 0F, new Paint());
        }

        for (int i = 0; i <= this.h; i=i+gridWidth)
        {
            canvas.drawLine(0, i, getWidth(), i,
                    lines);
        }

        for (int i = 0; i <= this.w; i=i+gridWidth)
        {
            canvas.drawLine(i, 0, i, getHeight(),
                    lines);
        }

        lines.setColor(Color.BLACK);


    }

    /**
     * This method updates the instance of Canvas (View)
     *
     * @param canvas the new instance of Canvas
     */
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        
        if(drawGridEnabled) {
            this.drawGrid(canvas);
        }


        for (int i = 0; i < this.historyPointer; i++) {

            Paint paint = this.paintLists.get(i);

            Object drawable = this.objectLists.get(i);

            if(drawable.getClass() == Path.class) {
                canvas.drawPath((Path) drawable, paint);
            }
            if(drawable.getClass() == StartingBitmap.class) {
                StartingBitmap s = (StartingBitmap) drawable;
                canvas.drawBitmap(s.bitmapData, 0, 0, paint);
            }


            if(drawable.getClass() == StampBitmap.class){
                StampBitmap s = (StampBitmap) drawable;
                canvas.drawBitmap(s.bitmapData, s.xLocation, s.yLocation, paint);
            }

            if(drawable.getClass() == TextStamp.class){
                TextStamp s = (TextStamp) drawable;


                if (s.textValue.length() <= 0) {
                    return;
                }


                float textX = s.xLocation;
                float textY = s.yLocation;

                Paint paintForMeasureText = new Paint();

                // Line break automatically
                float textLength   = paintForMeasureText.measureText(s.textValue);
                float lengthOfChar = textLength / (float)s.textValue.length();
                float restWidth    = this.canvas.getWidth() - textX;  // text-align : right
                int numChars       = (lengthOfChar <= 0) ? 1 : (int)Math.floor((double)(restWidth / lengthOfChar));  // The number of characters at 1 line
                int modNumChars    = (numChars < 1) ? 1 : numChars;
                float y            = textY;
//
//                for (int j = 0, len = this.text.length(); j < len; j += modNumChars) {
//                    String substring = "";
//
//                    if ((j + modNumChars) < len) {
//                        substring = this.text.substring(j, (j + modNumChars));
//                    } else {
//                        substring = this.text.substring(i, len);
//                    }
//
//                    y += this.fontSize;

                canvas.drawText(s.textValue, textX, y, paint);
                //}


            }


        }

        canvas.save();

        // ...
        // your canvas-drawing code
        // ...

        canvas.restore();

        this.canvas = canvas;
    }

    /**
     * This method set event listener for drawing.
     *
     * @param event the instance of MotionEvent
     * @return
     */
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        detector.onTouchEvent(event);
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                this.onActionDown(event);
                break;
            case MotionEvent.ACTION_MOVE :
                this.onActionMove(event);
                break;
            case MotionEvent.ACTION_UP :
                this.onActionUp(event);
                break;
            default :
                break;
        }

        // Re draw
        this.invalidate();

        return true;
    }

    /**
     * This method is getter for mode.
     *
     * @return
     */
    public Mode getMode() {
        return this.mode;
    }

    /**
     * This method is setter for mode.
     *
     * @param mode
     */
    public void setMode(Mode mode) {
        this.mode = mode;
    }

    /**
     * This method is getter for drawer.
     *
     * @return
     */
    public Drawer getDrawer() {
        return this.drawer;
    }

    /**
     * This method is setter for drawer.
     *
     * @param drawer
     */
    public void setDrawer(Drawer drawer) {
        this.drawer = drawer;
    }

    /**
     * This method draws canvas aetdain for Undo.
     *
     * @return If Undo is enabled, this is returned as true. Otherwise, this is returned as false.
     */
    public boolean undo() {
        if (this.historyPointer > 1) {
            this.historyPointer--;
            this.invalidate();

            return true;
        } else {
            return false;
        }
    }

    /**
     * This method draws canvas again for Redo.
     *
     * @return If Redo is enabled, this is returned as true. Otherwise, this is returned as false.
     */
    public boolean redo() {
        if (this.historyPointer < this.objectLists.size()) {
            this.historyPointer++;
            this.invalidate();

            return true;
        } else {
            return false;
        }
    }

    /**
     * This method initializes canvas.
     *
     * @return
     */
    public void clear() {

        for (int i = 0;i < this.paintLists.size(); i++) {
            this.objectLists.remove(i);
            this.paintLists.remove(i);
        }
        this.historyPointer = 0;

        this.text = "";

        // Clear
        this.invalidate();
    }

    /**
     * This method is getter for canvas background color
     *
     * @return
     */
    public int getBaseColor() {
        return this.baseColor;
    }

    /**
     * This method is setter for canvas background color
     *
     * @param color
     */
    public void setBaseColor(int color) {
        this.baseColor = color;
    }

    /**
     * This method is getter for drawn text.
     *
     * @return
     */
    public String getText() {
        return this.text;
    }

    /**
     * This method is setter for drawn text.
     *
     * @param text
     */
    public void setText(String text) {
        this.text = text;
    }

    /**
     * This method is getter for stroke or fill.
     *
     * @return
     */
    public Paint.Style getPaintStyle() {
        return this.paintStyle;
    }

    /**
     * This method is setter for stroke or fill.
     *
     * @param style
     */
    public void setPaintStyle(Paint.Style style) {
        this.paintStyle = style;
    }

    /**
     * This method is getter for stroke color.
     *
     * @return
     */
    public int getPaintStrokeColor() {
        return this.paintStrokeColor;
    }

    /**
     * This method is setter for stroke color.
     *
     * @param color
     */
    public void setPaintStrokeColor(int color) {
        this.paintStrokeColor = color;
    }

    /**
     * This method is getter for fill color.
     * But, current Android API cannot set fill color (?).
     *
     * @return
     */
    public int getPaintFillColor() {
        return this.paintFillColor;
    };

    /**
     * This method is setter for fill color.
     * But, current Android API cannot set fill color (?).
     *
     * @param color
     */
    public void setPaintFillColor(int color) {
        this.paintFillColor = color;
    }

    /**
     * This method is getter for stroke width.
     *
     * @return
     */
    public float getPaintStrokeWidth() {
        return this.paintStrokeWidth;
    }

    /**
     * This method is setter for stroke width.
     *
     * @param width
     */
    public void setPaintStrokeWidth(float width) {
        if (width >= 0) {
            this.paintStrokeWidth = width;
        } else {
            this.paintStrokeWidth = 3F;
        }
    }

    /**
     * This method is getter for alpha.
     *
     * @return
     */
    public int getOpacity() {
        return this.opacity;
    }

    /**
     * This method is setter for alpha.
     * The 1st argument must be between 0 and 255.
     *
     * @param opacity
     */
    public void setOpacity(int opacity) {
        if ((opacity >= 0) && (opacity <= 255)) {
            this.opacity = opacity;
        } else {
            this.opacity= 255;
        }
    }

    /**
     * This method is getter for amount of blur.
     *
     * @return
     */
    public float getBlur() {
        return this.blur;
    }

    /**
     * This method is setter for amount of blur.
     * The 1st argument is greater than or equal to 0.0.
     *
     * @param blur
     */
    public void setBlur(float blur) {
        if (blur >= 0) {
            this.blur = blur;
        } else {
            this.blur = 0F;
        }
    }

    /**
     * This method is getter for line cap.
     *
     * @return
     */
    public Paint.Cap getLineCap() {
        return this.lineCap;
    }

    /**
     * This method is setter for line cap.
     *
     * @param cap
     */
    public void setLineCap(Paint.Cap cap) {
        this.lineCap = cap;
    }

    /**
     * This method is getter for font size,
     *
     * @return
     */
    public float getFontSize() {
        return this.fontSize;
    }

    /**
     * This method is setter for font size.
     * The 1st argument is greater than or equal to 0.0.
     *
     * @param size
     */
    public void setFontSize(float size) {
        if (size >= 0F) {
            this.fontSize = size;
        } else {
            this.fontSize = 32F;
        }
    }

    /**
     * This method is getter for font-family.
     *
     * @return
     */
    public Typeface getFontFamily() {
        return this.fontFamily;
    }

    /**
     * This method is setter for font-family.
     *
     * @param face
     */
    public void setFontFamily(Typeface face) {
        this.fontFamily = face;
    }

    /**
     * This method gets current canvas as bitmap.
     *
     * @return This is returned as bitmap.
     */
    public Bitmap getBitmap() {
        this.setDrawingCacheEnabled(false);
        this.setDrawingCacheEnabled(true);
        drawGridEnabled = false;
        this.buildDrawingCache();
        Bitmap bm = Bitmap.createBitmap(this.getDrawingCache());
        drawGridEnabled = true;
        return bm;
    }

    /**
     * This method gets current canvas as scaled bitmap.
     *
     * @return This is returned as scaled bitmap.
     */
    public Bitmap getScaleBitmap(int w, int h) {
        this.setDrawingCacheEnabled(false);
        this.setDrawingCacheEnabled(true);

        return Bitmap.createScaledBitmap(this.getDrawingCache(), w, h, true);
    }

    /**
     * This method draws the designated bitmap to canvas.
     *
     * @param bitmap
     */
    public void drawBitmap(Bitmap bitmap) {
        this.bitmap = bitmap;
        this.invalidate();
    }

    /**
     * This method draws the designated byte array of bitmap to canvas.
     *
     * @param byteArray This is returned as byte array of bitmap.
     */
    public void drawBitmap(byte[] byteArray) {
        this.drawBitmap(BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length));
    }

    /**
     * This static method gets the designated bitmap as byte array.
     *
     * @param bitmap
     * @param format
     * @param quality
     * @return This is returned as byte array of bitmap.
     */
    public static byte[] getBitmapAsByteArray(Bitmap bitmap, CompressFormat format, int quality) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(format, quality, byteArrayOutputStream);

        return byteArrayOutputStream.toByteArray();
    }

    /**
     * This method gets the bitmap as byte array.
     *
     * @param format
     * @param quality
     * @return This is returned as byte array of bitmap.
     */
    public byte[] getBitmapAsByteArray(CompressFormat format, int quality) {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        this.getBitmap().compress(format, quality, byteArrayOutputStream);

        return byteArrayOutputStream.toByteArray();
    }


    /**
     * This method gets the bitmap as byte array.
     * Bitmap format is PNG, and quality is 100.
     *
     * @return This is returned as byte array of bitmap.
     */
    public byte[] getBitmapAsByteArray() {
        return this.getBitmapAsByteArray(CompressFormat.PNG, 100);
    }


}
