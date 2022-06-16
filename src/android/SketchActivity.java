package com.formpigeon.sketch;
import android.app.Application;
import android.content.res.Resources;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import com.formpigeon.formpigeon.R;
import android.net.Uri;
import android.os.Bundle;
import android.app.Activity;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.os.Handler;
import android.content.DialogInterface;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;
import android.widget.Toast;
import com.formpigeon.sketch.CanvasView;
import com.formpigeon.sketch.StampActivity;
import java.io.ByteArrayOutputStream;
import android.graphics.Bitmap;
import android.util.Base64;
import com.github.clans.fab.FloatingActionButton;
import android.content.Context;
import com.github.clans.fab.FloatingActionMenu;
import android.app.AlertDialog;
import android.widget.EditText;
import android.text.InputType;
import android.view.LayoutInflater;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaActivity;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import com.formpigeon.sketch.ImageAdapter;
import com.google.gson.Gson;
import com.formpigeon.sketch.ResultIPC;
import java.util.concurrent.ExecutorService;

public class SketchActivity extends CordovaActivity {

    private FloatingActionButton fab1;
    private FloatingActionButton fab2;
    private FloatingActionButton fab3;
    private List<FloatingActionMenu> menus = new ArrayList();
    private Intent stampActivity = null;
    private CanvasView canvas     = null;
    private Handler mUiHandler = new Handler();
    private ImageAdapter imageAdapter = new ImageAdapter(this);
    ArrayList<String> stampValues = null;
    ArrayList<String> stampTitles = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        this.setTheme(R.style.Theme_AppCompat_Light);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.sketch_activity);

        this.canvas = (CanvasView)this.findViewById(R.id.canvas);


        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;
        int height = size.y;

        double finalWidth = size.x;
        double finalHeight = size.y;

        if( finalWidth / 0.75 > finalHeight){
            finalWidth = finalHeight * 1.25;
        } else {
            finalHeight = finalWidth / 0.75;
        }




        this.canvas.gridWidth = (int) finalWidth / 32;

        finalWidth = finalWidth - (finalWidth % this.canvas.gridWidth);
        finalHeight = finalHeight - (finalHeight % this.canvas.gridWidth);

        this.canvas.setLayoutParams(new LinearLayout.LayoutParams((int) finalWidth, (int) finalHeight));

        this.canvas.w = finalWidth;
        this.canvas.h = finalHeight;
        canvas.clear();



        canvas.clear();
        String existingImage = getIntent().getExtras().getString("existingImageString");

        if(existingImage.length() == 0){

        } else {


            byte[] decodedString = Base64.decode(existingImage.substring(existingImage.indexOf(",") + 1), Base64.DEFAULT);
            Bitmap image = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
            canvas.updateHistory(canvas.createStartingImage(image));

        }

        Gson gsonReceiver = new Gson();

        int sync = getIntent().getIntExtra("bigdata:synccode", -1);
        final String bigData = ResultIPC.get().getLargeData(sync);

        stampValues = gsonReceiver.fromJson(bigData, ArrayList.class);

        stampTitles = gsonReceiver.fromJson(getIntent().getExtras().getString("stampTitles"), ArrayList.class);

        for(Iterator<String> i = stampValues.iterator(); i.hasNext(); ) {
            String item = i.next();
            byte[] decodedString = Base64.decode(item.substring(item.indexOf(",") + 1), Base64.DEFAULT);
            Bitmap image = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
            imageAdapter.imageArray.add(image);

        }
        imageAdapter.titleArray = stampTitles;
        final FloatingActionMenu shapeMenu = (FloatingActionMenu) findViewById(R.id.shapeMenu);

        final FloatingActionButton undo = (FloatingActionButton) findViewById(R.id.undo);
        final FloatingActionButton redo = (FloatingActionButton) findViewById(R.id.redo);
        final FloatingActionButton clear = (FloatingActionButton) findViewById(R.id.clear);
        final FloatingActionButton text = (FloatingActionButton) findViewById(R.id.text);
        final FloatingActionButton stamp = (FloatingActionButton) findViewById(R.id.stamp);
        final FloatingActionButton exit = (FloatingActionButton) findViewById(R.id.exit);

        undo.setOnClickListener(clickListener);
        redo.setOnClickListener(clickListener);
        clear.setOnClickListener(clickListener);
        text.setOnClickListener(clickListener);
        stamp.setOnClickListener(clickListener);
        exit.setOnClickListener(clickListener);



        //System.out.println(getIntent().getStringExtra("json"));
        shapeMenu.setOnMenuButtonClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                shapeMenu.toggle(true);
            }
        });

        menus.add(shapeMenu);

        shapeMenu.hideMenuButton(false);


        int delay = 400;
        for (final FloatingActionMenu menu : menus) {
            mUiHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    menu.showMenuButton(true);
                }
            }, delay);
            delay += 150;
        }

        shapeMenu.setClosedOnTouchOutside(true);
        fab1 = (FloatingActionButton) findViewById(R.id.line);
        fab2 = (FloatingActionButton) findViewById(R.id.circle);
        fab3 = (FloatingActionButton) findViewById(R.id.rectangle);


        fab1.setOnClickListener(clickListener);
        fab2.setOnClickListener(clickListener);
        fab3.setOnClickListener(clickListener);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void openClearDialog (){


        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Clear Sketch?");
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                canvas.clear();
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();







    }
    private void openExitDialog (){


        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Save and Exit?");
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {

                Intent resultIntent = new Intent();
                Bitmap image = canvas.getBitmap();

                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                boolean result = image.compress(Bitmap.CompressFormat.PNG, 100, baos);
                byte[] b = baos.toByteArray();
                String imageEncoded = Base64.encodeToString(b, Base64.NO_WRAP);
                imageEncoded = "data:image/png;base64," + imageEncoded;
                System.out.println(imageEncoded);
                resultIntent.putExtra("resultImage", imageEncoded);
                setResult(Activity.RESULT_OK, resultIntent);
                finish();
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();







    }

    private View.OnClickListener clickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            String text = "";
            final FloatingActionMenu shapeMenu = (FloatingActionMenu) findViewById(R.id.shapeMenu);


            int id =  v.getId();

            if(id == R.id.undo) {
                canvas.undo();
            } else if(id == R.id.redo) {
                canvas.redo();
            } else if(id == R.id.clear) {

                openClearDialog();


            } else if (id == R.id.text) {
                textStart();
            } else if(id == R.id.stamp) {
                stampStart();
            } else if(id == R.id.line) {
                canvas.setText("");
                canvas.setMode(CanvasView.Mode.DRAW);
                canvas.setDrawer(CanvasView.Drawer.LINE);
                shapeMenu.close(true);
            } else if(id == R.id.circle) {
                canvas.setText("");
                canvas.setMode(CanvasView.Mode.DRAW);
                canvas.setDrawer(CanvasView.Drawer.ELLIPSE);
                shapeMenu.close(true);
            } else if(id == R.id.rectangle) {
                canvas.setText("");
                canvas.setMode(CanvasView.Mode.DRAW);
                canvas.setDrawer(CanvasView.Drawer.RECTANGLE);
                shapeMenu.close(true);
            } else if(id == R.id.exit) {

                openExitDialog();

            }




        }
    };

    public void stampStart(){


        LayoutInflater layoutInflater = (LayoutInflater)getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        final View inflatedView = layoutInflater.inflate(R.layout.stamp_activity, null, false);


        final GridView gridview = (GridView) inflatedView.findViewById(R.id.gridview);
        gridview.setAdapter(this.imageAdapter);



        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);

        final PopupWindow popWindow = new PopupWindow(inflatedView, RelativeLayout.LayoutParams.FILL_PARENT, RelativeLayout.LayoutParams.FILL_PARENT, true );

        popWindow.setFocusable(true);

        popWindow.setOutsideTouchable(true);

        popWindow.showAtLocation(inflatedView, Gravity.BOTTOM, 0, 150);


        gridview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            public void onItemClick(AdapterView<?> parent, View v,
                                    int position, long id) {
                Bitmap i = (Bitmap)imageAdapter.imageArray.get(position);

                canvas.setMode(CanvasView.Mode.STAMP);
                canvas.stamp = i;
                popWindow.dismiss();

            }
        });


    }

    public void textStart(){

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Choose Text Label");

// Set up the input
        final EditText input = new EditText(this);
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setInputType(InputType.TYPE_CLASS_TEXT);
        builder.setView(input);

// Set up the buttons
        builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                canvas.setText(input.getText().toString());
                canvas.setMode(CanvasView.Mode.TEXT);
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();


    }


}


