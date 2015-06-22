package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class SetNativeLogEnabledFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		Boolean nativeLogEnabled = getBooleanFromFREObject(args[0]);

		AirFacebookExtension.nativeLogEnabled = nativeLogEnabled;
		
		return null;
	}

}
