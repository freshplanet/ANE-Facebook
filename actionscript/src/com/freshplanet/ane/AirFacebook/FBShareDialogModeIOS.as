package com.freshplanet.ane.AirFacebook {

/**
 * Modes for the FBSDKShareDialog.
 *
 * @see http://developers.facebook.com/docs/reference/ios/current/constants/FBSDKShareDialogMode/
 */
public class FBShareDialogModeIOS {

    /**
     * Acts with the most appropriate mode that is available.
     */
    public static const AUTOMATIC:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 0);
    /**
     * Displays the dialog in the main native Facebook app.
     */
    public static const NATIVE:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 1);
    /**
     * Displays the dialog in the iOS integrated share sheet.
     */
    public static const SHARE_SHEET:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 2);
    /**
     * Displays the dialog in Safari.
     */
    public static const BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 3);
    /**
     * Displays the dialog in a UIWebView within the app.
     */
    public static const WEB:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 4);
    /**
     * Displays the feed dialog in Safari.
     */
    public static const FEED_BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 5);
    /**
     * Displays the feed dialog in a UIWebView within the app.
     */
    public static const FEED_WEB:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 6);

    private var _value:int;

    public function FBShareDialogModeIOS(access:Class, value:int)
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
