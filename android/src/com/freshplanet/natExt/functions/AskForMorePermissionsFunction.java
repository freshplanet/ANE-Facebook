package com.freshplanet.natExt.functions;

import android.content.Intent;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.natExt.FBLoginActivity;

public class AskForMorePermissionsFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		FREArray permissionsArray = (FREArray) arg1[0];
		
		long arrayLength;
		try {
			arrayLength = permissionsArray.getLength();

		} catch (FREInvalidObjectException e1) {
			e1.printStackTrace();
			arrayLength = 0;
		} catch (FREWrongThreadException e1) {
			e1.printStackTrace();
			arrayLength = 0;
		} catch (Exception e1)
		{
			e1.printStackTrace();
			arrayLength = 0;
		}


		String[] permissions = new String[(int) arrayLength];

		for (int i = 0; i < arrayLength; i++)
		{
			Log.d("as2fb", "for i - "+Integer.toString(i));

			try
			{
				permissions[i] =  permissionsArray.getObjectAt((long) i).getAsString();
				Log.d("as2fb", "for i - "+permissions[i]);
			} catch (IllegalStateException e) {
				Log.d("as2fb", "Illegal State Exception");
				e.printStackTrace();
				permissions[i] = null;
			} catch (FRETypeMismatchException e) {
				Log.d("as2fb", "Type Mismatch Exception ");
				e.printStackTrace();
				permissions[i] = null;
			} catch (FREInvalidObjectException e) {
				Log.d("as2fb", "Invalie Object Exception ");
				e.printStackTrace();
				permissions[i] = null;
			} catch (FREWrongThreadException e) {
				Log.d("as2fb", "Wrong Thread Exception ");
				e.printStackTrace();
				permissions[i] = null;
			} catch (Exception e)
			{
				e.printStackTrace();
				permissions[i] = null;
			}
		}
				
		
		Log.d("as2fb", "startLogin2");
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBLoginActivity.class);
		i.putExtra("permissions", permissions);
		i.putExtra("forceAuthorize", true);
		arg0.getActivity().startActivity(i);
		
		
		return null;	
	}

}
