package com.freshplanet.ane.AirFacebook.functions;

import android.os.Bundle;
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
		final String callback = getStringFromFREObject(args[1]);

		Bundle metaData = context.getActivity().getApplicationContext().getApplicationInfo().metaData;
		String appIdFromMetadata = metaData != null ? metaData.getString("com.facebook.sdk.ApplicationId") : null;
		AirFacebookExtension.log("FB application ID from AndroidManifest.xml: " + appIdFromMetadata != null ? appIdFromMetadata : "no metadata");

		if(appIdFromMetadata == null && appID != null) {

			AirFacebookExtension.context.setAppID(appID);
			FacebookSdk.setApplicationId(appID);
		}

		AirFacebookExtension.log("Initializing with application ID " + FacebookSdk.getApplicationId());

		FacebookSdk.sdkInitialize(context.getActivity().getApplicationContext(), new FacebookSdk.InitializeCallback() {
			@Override
			public void onInitialized() {

				AirFacebookExtension.log("Facebook sdk initialized.");

				if (AirFacebookExtension.context != null && callback != null) {

					AirFacebookExtension.context.dispatchStatusEventAsync("SDKINIT_" + callback, "");
				}
			}
		});

		return null;
	}
}