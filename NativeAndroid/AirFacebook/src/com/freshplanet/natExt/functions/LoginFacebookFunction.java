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

public class LoginFacebookFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		Log.d("as2fb", "startLogin");
		Log.d("as3fb", arg1.toString());
		
		FREArray permissionsArray = (FREArray) arg1[0];
		
		Log.d("as2fb", "convert to FREArray");

		long arrayLength;
		try {
			arrayLength = permissionsArray.getLength();
			Log.d("as2fb", "get array length" +Long.toString(arrayLength));

		} catch (FREInvalidObjectException e1) {
			Log.d("as2fb", "invalid object exception");

			e1.printStackTrace();
			arrayLength = 0;
		} catch (FREWrongThreadException e1) {
			Log.d("as2fb", "wrong thread exception");
			
			e1.printStackTrace();
			arrayLength = 0;
		}

		
		Log.d("as2fb", "Create String[]");

		String[] permissions = new String[(int) arrayLength];

		for (int i = 0; i < arrayLength; i++)
		{
			Log.d("as2fb", "for i - "+Integer.toString(i));

			try
			{
				permissions[i] =  permissionsArray.getObjectAt((long) i).getAsString();
				Log.d("as2fb", "for i - "+permissions[i]);
			} catch (IllegalStateException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Illegal State Exception");
				e.printStackTrace();
				permissions[i] = null;
			} catch (FRETypeMismatchException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Type Mismatch Exception ");
				e.printStackTrace();
				permissions[i] = null;
			} catch (FREInvalidObjectException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Invalie Object Exception ");

				e.printStackTrace();
				permissions[i] = null;
			} catch (FREWrongThreadException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Wrong Thread Exception ");

				e.printStackTrace();
				permissions[i] = null;
			}
		}
				
		Log.d("as3fb", permissions.toString());
		
		Log.d("as2fb", "startLogin2");
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBLoginActivity.class);
		i.putExtra("permissions", permissions);
		arg0.getActivity().startActivity(i);
		
		
		return null;
	}

}
