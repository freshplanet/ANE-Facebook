package com.freshplanet.ane.AirFacebook {

/**
 * The mode for the share dialog.
 *
 * @see http://developers.facebook.com/docs/reference/android/current/class/ShareDialog.Mode/
 */
public class FBShareDialogModeAndroid {

    /**
     * The mode is determined automatically.
     */
    public static const AUTOMATIC:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 0);
    /**
     * The native dialog is used.
     */
    public static const NATIVE:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 1);
    /**
     * The web dialog is used.
     */
    public static const WEB:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 2);
    /**
     * The feed dialog is used.
     */
    public static const FEED:FBShareDialogModeAndroid = new FBShareDialogModeAndroid(Private, 3);

    private var _value:int;

    public function FBShareDialogModeAndroid(access:Class, value:int)
    {
        if(access != Private){
            throw new Error("Private constructor call!");
        }

        _value = value;
    }

    public function get value():int
    {
        return _value;
    }
}
}

final class Private{}
