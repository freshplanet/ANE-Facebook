package com.freshplanet.natExt.functions;

import android.content.Intent;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBLoginActivity;

public class AskForMorePermissionsFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve permissions array length
		FREArray permissionsArray = (FREArray)arg1[0];
		
		long arrayLength = 0;
		try
		{
			arrayLength = permissionsArray.getLength();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
		}
		
		// Retrieve permissions
		String[] permissions = new String[(int)arrayLength];
		for (int i = 0; i < arrayLength; i++)
		{
			try
			{
				permissions[i] =  permissionsArray.getObjectAt((long) i).getAsString();
			}
			catch (Exception e)
			{
				e.printStackTrace();
				arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
				permissions[i] = null;
			}
		}
		
		// Start login activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBLoginActivity.class);
		i.putExtra("permissions", permissions);
		i.putExtra("forceAuthorize", true);
		arg0.getActivity().startActivity(i);
		
		return null;	
	}
}