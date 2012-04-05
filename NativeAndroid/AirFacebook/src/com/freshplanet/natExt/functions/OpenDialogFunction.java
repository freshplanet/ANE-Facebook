package com.freshplanet.natExt.functions;

import android.content.Intent;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.natExt.FBDialogActivity;

public class OpenDialogFunction implements FREFunction{

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		String method = null;
		String message = null;
		String to = null;
		
		//method
		try {
			method = arg1[0].getAsString();
			Log.d("as2fb", "method: "+method);
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		try {
			message = arg1[1].getAsString();
			Log.d("as2fb", "message: "+message);

		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		}
		
		
		if (arg1[2] != null)
		{
			try {
				to = arg1[2].getAsString();
				Log.d("as2fb", "to: "+to);
			} catch (IllegalStateException e) {
				e.printStackTrace();
			} catch (FRETypeMismatchException e) {
				e.printStackTrace();
			} catch (FREInvalidObjectException e) {
				e.printStackTrace();
			} catch (FREWrongThreadException e) {
				e.printStackTrace();
			}
		}
		
		Log.d("as2fb", "creating bundle...");
		
		Log.d("as2fb", "sending dialog");

		Intent i = new Intent(arg0.getActivity().getApplicationContext(), FBDialogActivity.class);
		i.putExtra("message", message);
		i.putExtra("method", method);
		if (to != null && to.length() > 0)
		{
			i.putExtra("to", to);
		}
		
		arg0.getActivity().startActivity(i);
		
		return null;
	}

}
