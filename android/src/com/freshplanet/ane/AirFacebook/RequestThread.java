package com.freshplanet.ane.AirFacebook;

import android.os.Bundle;

import com.facebook.AccessToken;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;

public class RequestThread extends Thread
{
	private AirFacebookExtensionContext _context;
	
	private String _graphPath;
	private Bundle _parameters;
	private String _httpMethod;
	private String _callback;
	
	public RequestThread(AirFacebookExtensionContext context, String graphPath, Bundle parameters, String httpMethod, String callback)
	{
		_context = context;
		_graphPath = graphPath;
		_parameters = parameters;
		_httpMethod = httpMethod;
		_callback = callback;
	}
	
    @Override 
    public void run()
    {
		AccessToken accessToken = AccessToken.getCurrentAccessToken();

    	String data = null;
		String error = null;
		try
		{
			GraphRequest request = new GraphRequest(accessToken, _graphPath, _parameters, HttpMethod.valueOf(_httpMethod));

			// TODO: investigate this and do some kind of fix - cannot be true what is written below
			// If you remove the log statements before and after request.executeAndWait(), and if the request
			// results in an error (such as lack of permissions), the app will CRASH and DIE. (libcore)
			// ( Possibly, something non-thread-safe is happening during executeAndWait() when there's an error )
			AirFacebookExtension.log("Before executing request (don't remove this log statement)");
			GraphResponse response = request.executeAndWait();
			AirFacebookExtension.log("After executing request  (don't remove this log statement)");
			
			
			if (response.getJSONObject() != null)
			{
				data = response.getJSONObject().toString();
			}
			else if (response.getJSONArray() != null)
			{
				data = response.getJSONArray().toString();
			}
			else if (response.getError() != null)
			{
				// error result
				if(response.getError().getRequestResult() != null)
				{
					error = response.getError().getRequestResult().toString();
				}
				// error on sending
				else
				{
					error = "{\"error\":\""+response.getError().toString()+"\"}";
				}
			}
		}
		catch (Exception e)
		{
			error = "{\"error\":\""+e.toString()+"\"}";
		}
		
		String result = "";
		if (error != null) result = error;
		else if (data != null) result = data;
			
		if (_callback != null)
		{
			_context.dispatchStatusEventAsync(_callback, result);
		}
    }	
}