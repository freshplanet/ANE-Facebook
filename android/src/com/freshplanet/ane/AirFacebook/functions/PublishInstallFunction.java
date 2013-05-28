package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.facebook.Settings;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class PublishInstallFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		
		String applicationId = null;
		
		try {
			applicationId = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		if (applicationId != null)
		{
			Settings.publishInstallAsync(arg0.getActivity(), applicationId);
		} else
		{
			AirFacebookExtension.log("cannot start publish install, applicationId is null");
		}
		
		return null;
	}

}
