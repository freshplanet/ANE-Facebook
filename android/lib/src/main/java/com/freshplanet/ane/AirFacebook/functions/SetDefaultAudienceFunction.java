package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.login.DefaultAudience;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class SetDefaultAudienceFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		DefaultAudience defaultAudience;

		int defaultAudienceInt = getIntFromFREObject(args[0]);
		switch (defaultAudienceInt){
			case 0: defaultAudience = DefaultAudience.FRIENDS; break;
			case 1: defaultAudience = DefaultAudience.ONLY_ME; break;
			case 2: defaultAudience = DefaultAudience.EVERYONE; break;
			default: defaultAudience = DefaultAudience.FRIENDS;
		}
		AirFacebookExtension.context.setDefaultAudience(defaultAudience);

		return null;
	}

}
