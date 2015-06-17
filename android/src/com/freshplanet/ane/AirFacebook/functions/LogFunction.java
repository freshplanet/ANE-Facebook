package com.freshplanet.ane.AirFacebook.functions;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

/**
 * Created by nodrock on 12/06/15.
 */
public class LogFunction extends BaseFunction {
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        String message = getStringFromFREObject(args[0]);

        Log.d("AirFacebook", "[FACEBOOK]" + message);

        return null;
    }
}
