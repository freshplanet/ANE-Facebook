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
		try
		{
			if (parameters != null)
			{
				data = AirFacebookExtensionContext.facebook.request(graphPath, parameters, httpMethod);
			}
			else
			{
				data = AirFacebookExtensionContext.facebook.request(graphPath);
			}
		}
		catch (Exception e)
		{
			context.dispatchStatusEventAsync(callback, e.getMessage());
		}
		
		// Trigger callback if necessary
		if (data != null && callback != null)
		{
			context.dispatchStatusEventAsync(callback, data);
		}
    }	
}