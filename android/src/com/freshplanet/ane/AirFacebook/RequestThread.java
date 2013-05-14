//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirFacebook;

import android.os.Bundle;

import com.adobe.fre.FREContext;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.HttpMethod;

public class RequestThread extends Thread
{
	private FREContext context;
	
	private String graphPath;
	private Bundle parameters;
	private String httpMethod;
	private String callback;
	
	public RequestThread(FREContext context, String graphPath, Bundle parameters, String httpMethod, String callback)
	{
		this.context = context;
		this.graphPath = graphPath;
		this.parameters = parameters;
		this.httpMethod = httpMethod;
		this.callback = callback;
	}
	
    @Override
    public void run()
    {
    	// Perform Facebook request
		String data = null;
		AirFacebookExtension.log("INFO - RequestThread.run");

		try
		{
			Request request;
			if (parameters != null)	{
				request = new Request(AirFacebookExtensionContext.session, graphPath, parameters, HttpMethod.valueOf(httpMethod));
			}
			else {
				request = new Request(AirFacebookExtensionContext.session, graphPath);
			}
			Response response = request.executeAndWait();
			if (response.getGraphObject() != null) {
				data = response.getGraphObject().getInnerJSONObject().toString();
			} else if (response.getGraphObjectList() != null) {
				data = response.getGraphObjectList().getInnerJSONArray().toString();
			} else if (response.getError() != null) {
				data = response.getError().getRequestResult().toString();
			}
			AirFacebookExtension.log("INFO - RequestThread.run, data = " + data);

		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - RequestThread.run, " + e.getMessage());
			
			String error = e.getMessage() != null ? e.getMessage() :  "";
			context.dispatchStatusEventAsync(callback, error);
		}
		
		// Trigger callback if necessary
		if (data != null && callback != null)
		{
			AirFacebookExtension.log("INFO - RequestThread.run, calling callback with data " + data);
			context.dispatchStatusEventAsync(callback, data);
		}
    }	
}