package com.formpigeon.sketch;

/**
 * Created by joshua on 11/10/16.
 */
public class ResultIPC {

    private static ResultIPC instance;

    public synchronized static ResultIPC get() {
        if (instance == null) {
            instance = new ResultIPC ();
        }
        return instance;
    }

    private int sync = 0;

    private String largeData;
    public int setLargeData(String largeData) {
        this.largeData = largeData;
        return ++sync;
    }

    public String getLargeData(int request) {
        return (request == sync) ? largeData : null;
    }
}
