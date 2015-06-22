/**
 * Created by nodrock on 17/06/15.
 */
package com.freshplanet.ane.AirFacebook {
public class FBShareDialogModeIOS {

    public static const AUTOMATIC:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 0);
    public static const NATIVE:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 1);
    public static const SHARE_SHEET:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 2);
    public static const BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 3);
    public static const WEB:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 4);
    public static const FEED_BROWSER:FBShareDialogModeIOS = new FBShareDialogModeIOS(Private, 5);
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
