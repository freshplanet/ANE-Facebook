package com.freshplanet.natExt.functions;

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBRequestThread;

/** Post an OpenGraph action. */
public class PostOGActionFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve the graph path
		String graphPath = null;
		try
		{
			graphPath = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", e.getMessage());
			return null;
		}
		
		// Retrieve the action parameters
		Bundle params = new Bundle();
		FREArray keyArray = (FREArray)arg1[1];
		FREArray valueArray = (FREArray)arg1[2];
		long arrayLength;
		try
		{
			arrayLength = keyArray.getLength();
			String key;
			String value;
			for (int i = 0; i < arrayLength; i++)
			{
				key =  keyArray.getObjectAt((long)i).getAsString();
				value = valueArray.getObjectAt((long)i).getAsString();
				params.putString(key, value);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", e.getMessage());
		}
		
		// Create a new thread
		FBRequestThread thread = new FBRequestThread(arg0, "", graphPath, params, "POST");
		thread.start();
		
		return null;
	}
}