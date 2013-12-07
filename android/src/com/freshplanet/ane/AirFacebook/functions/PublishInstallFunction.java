package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.Settings;

public class PublishInstallFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);
		
		String appID = getStringFromFREObject(args[0]);
		Settings.publishInstallAsync(context.getActivity(), appID);
		
		return null;
	}

}
