package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.login.DefaultAudience;
import com.facebook.share.widget.ShareDialog;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class SetDefaultShareDialogModeFunction extends BaseFunction {

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        ShareDialog.Mode defaultShareDialogMode;

        int defaultShareDialogModeInt = getIntFromFREObject(args[0]);
        switch (defaultShareDialogModeInt){
            case 0: defaultShareDialogMode = ShareDialog.Mode.AUTOMATIC; break;
            case 1: defaultShareDialogMode = ShareDialog.Mode.NATIVE; break;
            case 2: defaultShareDialogMode = ShareDialog.Mode.WEB; break;
            case 3: defaultShareDialogMode = ShareDialog.Mode.FEED; break;
            default: defaultShareDialogMode = ShareDialog.Mode.AUTOMATIC;
        }
        AirFacebookExtension.context.setDefaultShareDialogMode(defaultShareDialogMode);

        return null;
    }
}
