package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.LoginActivity;

public class ReauthorizeSessionWithPermissionsFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve permissions
		FREArray permissionsArray = (FREArray)arg1[0];
		String type = null;
		
		long arrayLength = 0;
		try
		{
			type = arg1[1].getAsString();
			arrayLength = permissionsArray.getLength();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		String[] permissions = new String[(int)arrayLength];
		for (int i = 0; i < arrayLength; i++)
		{
			try
			{
				permissions[i] =  permissionsArray.getObjectAt((long) i).getAsString();
			}
			catch (Exception e)
			{
				AirFacebookExtension.log("ERROR - " + e.getMessage());
				permissions[i] = null;
			}
		}
		
		// Start login activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), LoginActivity.class);
		i.putExtra("permissions", permissions);
		i.putExtra("reauthorize", true);
		i.putExtra("type", type);
		arg0.getActivity().startActivity(i);
		
		return null;	
	}
}