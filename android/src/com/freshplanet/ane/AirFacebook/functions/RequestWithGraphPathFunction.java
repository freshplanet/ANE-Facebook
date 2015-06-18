package com.freshplanet.ane.AirFacebook.functions;

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.RequestThread;

public class RequestWithGraphPathFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{	
		super.call(context, args);
		
		String graphPath = getStringFromFREObject(args[0]);
		Bundle parameters = getBundleOfStringFromFREArrays((FREArray)args[1], (FREArray)args[2]);
		String httpMethod = getStringFromFREObject(args[3]);
		String callback = getStringFromFREObject(args[4]);

		new RequestThread(AirFacebookExtension.context, graphPath, parameters, httpMethod, callback).start();
		
		return null;
	}
}