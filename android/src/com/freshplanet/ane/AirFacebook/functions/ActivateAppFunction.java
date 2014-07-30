
package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.AppEventsLogger;

public class ActivateAppFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		AppEventsLogger.activateApp(context.getActivity());
		
		return null;
	}

}
