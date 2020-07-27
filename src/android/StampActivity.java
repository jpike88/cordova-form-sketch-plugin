package com.formpigeon.sketch;
import android.app.Application;
import android.content.res.Resources;
import com.google.gson.Gson;
import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import com.formpigeon.sketch.StampActivity;
import android.app.Activity;
import com.formpigeon.sketch.ImageAdapter;
import java.util.Iterator;
import android.util.Base64;
import android.view.ContextThemeWrapper;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.AnimationUtils;
import android.view.animation.OvershootInterpolator;
import android.widget.Toast;
import android.widget.AdapterView;
import com.github.clans.fab.FloatingActionButton;
import com.github.clans.fab.FloatingActionMenu;
import android.widget.AdapterView.OnItemClickListener;
import java.util.ArrayList;
import java.util.List;
import android.widget.GridView;
import com.formpigeon.formpigeon.R;

/**
 * Created by joshua on 26/01/2016.
 */
public class StampActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stamp_activity);
        Bundle extras = getIntent().getExtras();

        String valStrings = getIntent().getExtras().getString("stampValues");
        String titleStrings = getIntent().getExtras().getString("stampTitles");

        Gson gsonReceiver = new Gson();
        List<String> stampValues = gsonReceiver.fromJson(valStrings, List.class);
        List<String> stampTitles = gsonReceiver.fromJson(titleStrings, List.class);
        ImageAdapter imageAdapter = new ImageAdapter(this);

        imageAdapter.titleArray.addAll(stampTitles);

        List<Bitmap> finalStampValues = new ArrayList();

        for(Iterator<String> i = stampValues.iterator(); i.hasNext(); ) {
            String item = i.next();
            byte[] decodedString = Base64.decode(item.substring(item.indexOf(",") + 1), Base64.DEFAULT);
            Bitmap image = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
            imageAdapter.imageArray.add(image);
        }






        final GridView gridview = (GridView) findViewById(R.id.gridview);
        gridview.setAdapter(imageAdapter);


        gridview.setOnItemClickListener(new OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View v,
                                    int position, long id) {
                Bitmap i = (Bitmap)gridview.getItemAtPosition(position);



                finish();
                setResult(Activity.RESULT_OK);

            }
        });


    }

}
