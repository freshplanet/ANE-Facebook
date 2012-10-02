package com.freshplanet.natExt.functions;

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBDialogActivity;

public class OpenFeedDialogFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve parameters
		String method = null;
		String message = null;
		String name = null;
		String picture = null;
		String link = null;
		String caption = null;
		String description = null;
		String friendsCsv = null;
		String callbackName = null;
		try
		{
			method = arg1[0].getAsString();
			message = arg1[1].getAsString();
			name = arg1[2].getAsString();
			picture = arg1[3].getAsString();
			link = arg1[4].getAsString();
			caption = arg1[5].getAsString();
			description = arg1[6].getAsString();
			if (arg1.length > 7 && arg1[7] != null)
			{
				friendsCsv = arg1[7].getAsString();
			}
			if (arg1.length > 8 && arg1[8] != null)
			{
				callbackName = arg1[8].getAsString();
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
			return null;
		}
		
		// Start Facebook Dialog activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBDialogActivity.class);
		i.putExtra("message", message);
		i.putExtra("method", method);
		i.putExtra("name", name);
		i.putExtra("picture", picture);
		i.putExtra("link", link);
		i.putExtra("caption", caption);
		i.putExtra("description", description);
		i.putExtra("to", friendsCsv);
		i.putExtra("frictionless", false);
		i.putExtra("callback", callbackName); 
		arg0.getActivity().startActivity(i);
		
		return null;
	}
}