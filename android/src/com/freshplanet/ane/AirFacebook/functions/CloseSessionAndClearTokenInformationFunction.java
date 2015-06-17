package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.AccessToken;
import com.facebook.Profile;
import com.facebook.login.LoginManager;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class CloseSessionAndClearTokenInformationFunction extends BaseFunction
{	
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		AirFacebookExtension.log("CloseSessionAndClearTokenInformationFunction");

		AccessToken.setCurrentAccessToken(null);
		Profile.setCurrentProfile(null);
		LoginManager.getInstance().logOut();
		
		return null;
	}
	
}