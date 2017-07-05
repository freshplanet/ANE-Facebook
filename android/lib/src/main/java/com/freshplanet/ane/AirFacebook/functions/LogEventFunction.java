package com.freshplanet.ane.AirFacebook.functions;

import android.os.Bundle;
import com.adobe.fre.*;
import com.facebook.appevents.AppEventsLogger;

public class LogEventFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		try {
			FREObject eventNameObject = args[0].getProperty("eventName");
			FREObject valueToSumObject = args[0].getProperty("valueToSum");
			FREArray paramsKeysArray = (FREArray)args[0].getProperty("paramsKeys");
			FREArray paramsTypesArray = (FREArray)args[0].getProperty("paramsTypes");
			FREArray paramsValuesArray = (FREArray)args[0].getProperty("paramsValues");

			String eventNameString = eventNameObject.getProperty("value").getAsString();
			Double valueToSum = valueToSumObject.getAsDouble();

			Bundle parameters = getBundleFromFREArrays(paramsKeysArray, paramsTypesArray, paramsValuesArray);

			AppEventsLogger logger = AppEventsLogger.newLogger(context.getActivity().getApplicationContext());
			logger.logEvent(eventNameString, valueToSum, parameters);

		} catch (FRETypeMismatchException | FREInvalidObjectException | FREASErrorException | FRENoSuchNameException | FREWrongThreadException e) {
			e.printStackTrace();
		}

		return null;
	}

}
