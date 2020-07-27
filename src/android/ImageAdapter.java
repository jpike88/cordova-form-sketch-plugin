package com.formpigeon.cordova.plugin.cordovaFormSketchPlugin;
import android.view.LayoutInflater;
import android.widget.BaseAdapter;
import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.view.ViewGroup;
import android.util.Base64;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import com.formpigeon.sketch.ImageCaption;
import java.util.ArrayList;
import android.widget.TextView;

/**
 * Created by joshua on 27/01/2016.
 */
public class ImageAdapter extends BaseAdapter {
    private Context mContext;

    public ArrayList imageArray = new ArrayList();
    public ArrayList titleArray = new ArrayList();

    public ImageAdapter(Context c) {
        mContext = c;
    }

    public int getCount() {
        return imageArray.size();
    }

    public Object getItem(int position) {
        return null;
    }

    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            LayoutInflater i = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = (View) i.inflate(R.layout.stamp_item, parent, false);
        }

        TextView t = (TextView) convertView.findViewById(R.id.label);
        ImageView i = (ImageView) convertView.findViewById(R.id.image);

        t.setText((String)titleArray.get(position));
        i.setImageBitmap((Bitmap) imageArray.get(position));

        return convertView;
    }


}