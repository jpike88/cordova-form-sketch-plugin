// Empty constructor
function CordovaFormSketchPlugin() { }

CordovaFormSketchPlugin.prototype.startSketch = function (existingPNGSketch, arrayOfStamps, successCallback, errorCallback) {


    const stampTitleArray = [];
    const stampArray = [];

    for (const stamp of arrayOfStamps) {
        stampTitleArray.push(stamp.label);
        stampArray.push(stamp.image);
    }

    var i = -1;
    var stampAddedCallback = function () {
        i++;
        if (stampArray[i] !== undefined) {
            cordova.exec(stampAddedCallback, errorCallback, "cordovaFormSketchPlugin", "loadStamp", [stampArray[i], stampTitleArray[i]]);
        } else {
            cordova.exec(successCallback, errorCallback, 'cordovaFormSketchPlugin', 'startSketch', [existingPNGSketch]);
        }
    }
    stampAddedCallback();


}

// Installation constructor that binds CordovaFormSketchPlugin to window
CordovaFormSketchPlugin.install = function () {
    if (!window.plugins) {
        window.plugins = {};
    }
    window.plugins.CordovaFormSketchPlugin = new CordovaFormSketchPlugin();
    return window.plugins.CordovaFormSketchPlugin;
};
cordova.addConstructor(CordovaFormSketchPlugin.install);
