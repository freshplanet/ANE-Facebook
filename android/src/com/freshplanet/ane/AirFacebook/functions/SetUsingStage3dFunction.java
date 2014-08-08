package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtensionContext;

public class SetUsingStage3dFunction extends BaseFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) 
	{
		
		super.call(context, args);
		
		((AirFacebookExtensionContext) context).usingStage3D = getBooleanFromFREObject(args[0]);
		
		return null;
		
	}

}
