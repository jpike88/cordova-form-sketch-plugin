package com.formpigeon.sketch;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.widget.ImageView;
import android.content.Context;
/**
 * Created by joshua on 27/01/2016.
 */
public class ImageCaption extends ImageView {

    private String caption;

    public ImageCaption(Context c) {
        super(c);
    }

    public void setCaption(String caption) {
        this.caption = caption;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        Paint paintForMeasureText = new Paint();

        float textLength   = paintForMeasureText.measureText(this.caption);
        float lengthOfChar = textLength / (float)this.caption.length();
        float restWidth    = canvas.getWidth();  // text-align : right
        int numChars       = (lengthOfChar <= 0) ? 1 : (int)Math.floor((double)(restWidth / lengthOfChar));  // The number of characters at 1 line
        int modNumChars    = (numChars < 1) ? 1 : numChars;
        float y            = canvas.getHeight() - 10;

        for (int i = 0, len = this.caption.length(); i < len; i += modNumChars) {
            String substring = "";

            if ((i + modNumChars) < len) {
                substring = this.caption.substring(i, (i + modNumChars));
            } else {
                substring = this.caption.substring(i, len);
            }

            Paint p = new Paint();
            p.setTextSize(20);
            canvas.drawText(substring, 10, y, p);
        }

    }
}
