package com.formpigeon.cordova.plugin.cordovaFormSketchPlugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import android.content.Intent;
import com.google.gson.Gson;
import com.uservoice.uservoicesdk.*;
import com.uservoice.uservoicesdk.Config;
import com.uservoice.uservoicesdk.activity.PortalActivity;
import com.formpigeon.sketch.ResultIPC;
import android.app.Activity;
import android.content.Context;

import java.util.ArrayList;
import java.util.List;

public class cordovaFormSketchPlugin extends CordovaPlugin {

    private List stampValues = new ArrayList();
    private List stampTitles = new ArrayList();
    private CallbackContext cbc  = null;
    private Config uservoiceConfig = null;
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        final Context context=this.cordova.getActivity().getApplicationContext();
        this.cbc = callbackContext;

        // start sketch.

        // load stamp.

        // load image.

        if (action.equals("startSketch")) {

            Intent intent = new Intent(context, com.formpigeon.sketch.SketchActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

            String existingImage = (String)data.get(0);

            String json = new Gson().toJson(stampValues);
            String json2 = new Gson().toJson(stampTitles);

            int sync = ResultIPC.get().setLargeData(json.toString());
            intent.putExtra("bigdata:synccode", sync);

            intent.putExtra("stampTitles", json2.toString());
            intent.putExtra("existingImageString", existingImage);
            intent.setPackage(this.cordova.getActivity().getApplicationContext().getPackageName());

            intent.setFlags(0);
            this.cordova.startActivityForResult((CordovaPlugin) this, intent, 0x0ba7c0de);
            return true;

        } else if (action.equals("loadStamp")) {

            stampValues.add(data.get(0));
            stampTitles.add(data.get(1));

            callbackContext.success("derp");

            return true;

        } else if (action.equals("showHelpTopics")) {

            this.cordova.startActivityForResult((CordovaPlugin) this, new Intent(context, PortalActivity.class), 0x0ba7c0de);

        } else if (action.equals("initHelp")) {

            uservoiceConfig = new Config("reportwriter.uservoice.com");
            uservoiceConfig.setForumId(216495);
            UserVoice.init(uservoiceConfig, context);



        } else if(action.equals("configHelp")){

            uservoiceConfig.identifyUser(String.valueOf(data.get(0)), (String)data.get(1) + " " + (String)data.get(2), (String)data.get(3));

        }
        return false;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {

        if (resultCode == Activity.RESULT_OK) {

            cbc.success(intent.getStringExtra("resultImage"));
            // TODO Extract the data returned from the child Activity.
        }

    }


}
