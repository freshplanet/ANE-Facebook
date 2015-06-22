package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.login.LoginBehavior;
import com.facebook.share.widget.ShareDialog;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class SetLoginBehaviorFunction extends BaseFunction {

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        LoginBehavior loginBehavior;

        int loginBehaviorInt = getIntFromFREObject(args[0]);
        switch (loginBehaviorInt){
            case 0: loginBehavior = LoginBehavior.SSO_WITH_FALLBACK; break;
            case 1: loginBehavior = LoginBehavior.SSO_ONLY; break;
            case 2: loginBehavior = LoginBehavior.SUPPRESS_SSO; break;
            default: loginBehavior = LoginBehavior.SSO_WITH_FALLBACK;
        }
        AirFacebookExtension.context.setLoginBehavior(loginBehavior);

        return null;
    }
}
