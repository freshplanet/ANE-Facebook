package com.freshplanet.ane.AirFacebook.functions;

import java.util.List;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class ReauthorizeSessionWithPermissionsFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);
		
		List<String> permissions = getListOfStringFromFREArray((FREArray)args[0]);
		String type = getStringFromFREObject(args[1]);
		
		AirFacebookExtension.context.launchLoginActivity(permissions, type, true);
		
		return null;	
	}
}