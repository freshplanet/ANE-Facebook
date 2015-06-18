package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.FacebookSdk;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class InitFacebookFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

        String appID = getStringFromFREObject(args[0]);
		
		AirFacebookExtension.log("Initializing with application ID " + appID);

		if(appID != null) {

			AirFacebookExtension.context.setAppID(appID);
			FacebookSdk.setApplicationId(appID);
		}

		FacebookSdk.sdkInitialize(context.getActivity().getApplicationContext());
		
		return null;
	}
}