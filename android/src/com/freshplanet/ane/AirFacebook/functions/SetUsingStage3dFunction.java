package com.freshplanet.ane.AirFacebook.functions;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

public class SetUsingStage3dFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) 
	{
		AirFacebookExtensionContext context = (AirFacebookExtensionContext) arg0;
		try 
		{
			context.usingStage3D = arg1[0].getAsBool();
		} 
		catch (Exception e)
		{
			Log.e(AirFacebookExtension.TAG, e.getMessage());
		}
		return null;
	}

}
