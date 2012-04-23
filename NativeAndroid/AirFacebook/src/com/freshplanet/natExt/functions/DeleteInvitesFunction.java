package com.freshplanet.natExt.functions;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.freshplanet.natExt.FBRequestThread;

public class DeleteInvitesFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		// TODO Auto-generated method stub
		
		FREArray objectIds = (FREArray) arg1[0];

		long arrayLength;
		try {
			arrayLength = objectIds.getLength();

		} catch (FREInvalidObjectException e1) {
			Log.d("as2fb", "invalid object exception");

			e1.printStackTrace();
			arrayLength = 0;
		} catch (FREWrongThreadException e1) {
			Log.d("as2fb", "wrong thread exception");
			
			e1.printStackTrace();
			arrayLength = 0;
		} catch (Exception e)
		{
			e.printStackTrace();
			arrayLength = 0;
		}

		JSONArray batch_array = new JSONArray();
		
		for (int i = 0; i < arrayLength; i++)
		{
			Log.d("as2fb", "for i - "+Integer.toString(i));

			try
			{
				JSONObject deleteRequest = new JSONObject();
				deleteRequest.put("method", "DELETE");
				String requestPath = objectIds.getObjectAt(i).getAsString();
				deleteRequest.put("relative_url", requestPath);
			//	deleteRequest.put("relative_url", objectId.)
				batch_array.put(deleteRequest);
			} catch (IllegalStateException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Illegal State Exception");
				e.printStackTrace();
			} catch (FRETypeMismatchException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Type Mismatch Exception ");
				e.printStackTrace();
			} catch (FREInvalidObjectException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Invalie Object Exception ");

				e.printStackTrace();
			} catch (FREWrongThreadException e) {
				// TODO Auto-generated catch block
				Log.d("as2fb", "Wrong Thread Exception ");

				e.printStackTrace();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		Bundle params = new Bundle();
		
		params.putString("batch", batch_array.toString());
		
		FBRequestThread thread = new FBRequestThread(arg0, "deleteInvites", "me", params, "POST");
		thread.start();

		
		return null;
	}

}
