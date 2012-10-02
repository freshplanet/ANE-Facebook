package com.freshplanet.natExt.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBExtensionContext;

public class IsSessionValidFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		try
		{
			return FREObject.newObject(FBExtensionContext.facebook.isSessionValid());
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
			return null;
		}
	}
}