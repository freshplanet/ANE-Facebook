package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.Profile;

/**
 * Created by nodrock on 12/06/15.
 */
public class GetProfileFunction extends BaseFunction {

    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        Profile profile = Profile.getCurrentProfile();
        if (profile != null){
            try {

                FREObject result = FREObject.newObject("com.freshplanet.ane.AirFacebook.FBProfile", null);
                result.setProperty("firstName", FREObject.newObject(profile.getFirstName()));
                result.setProperty("lastName", FREObject.newObject(profile.getLastName()));
                result.setProperty("linkUrl", FREObject.newObject(profile.getLinkUri().toString()));
                result.setProperty("middleName", FREObject.newObject(profile.getMiddleName()));
                result.setProperty("name", FREObject.newObject(profile.getName()));
                result.setProperty("refreshDate", null);
                result.setProperty("userID", FREObject.newObject(profile.getId()));
                return result;
            } catch(Exception e) {
                e.printStackTrace();
                return null;
            }
        }

        return null;
    }
}
