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

public class OpenFeedDialogFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		String method = null;
		String message = null;
		String name = null;
		String picture = null;
		String link = null;
		String caption = null;
		String description = null;
		String friendsCsv = null;
		String callbackName = null;
		
		//method
		try {
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
		
		} catch (IllegalStateException e) {
			e.printStackTrace();
			return null;
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
			return null;
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
			return null;
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
			return null;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		
		Log.d("as2fb", "creating bundle...");
		
		Log.d("as2fb", "sending dialog");

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
		arg0.getActivity().startActivity(i);
		
		if (callbackName != null)
		{
			arg0.dispatchStatusEventAsync(callbackName, "{}");
		}
		
		return null;
	}

}
