package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.Settings;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class PublishInstallFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// Retrieve method
		String method = null;
		try
		{
			method = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		try
		{
			//get facebook appid
			String __appid = arg1[1].getAsString();
			Settings.publishInstallAsync(arg0.getActivity(), __appid);
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		return null;
	}

}
