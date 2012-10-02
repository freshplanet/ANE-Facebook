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

package com.freshplanet.natExt;

import android.os.Bundle;

import com.adobe.fre.FREContext;

public class FBRequestThread extends Thread
{
	private FREContext context;
	private String callbackName;
	private String graphPath;
	private String paramsString;
	private Bundle params;
	private String httpMethod;
	
	public FBRequestThread(FREContext context, String callbackName, String graphPath, String params)
	{
		this.paramsString = params;
		this.context = context;
		this.callbackName = callbackName;
		this.graphPath = graphPath;
		this.httpMethod = "GET";
	}
	
	public FBRequestThread(FREContext context, String callbackName, String graphPath, Bundle params, String httpMethod)
	{
		this.params = params;
		this.context = context;
		this.callbackName = callbackName;
		this.graphPath = graphPath;
		this.httpMethod = httpMethod;
	}
	
    @Override
    public void run()
    {
    	// Perform Facebook request
		String data = null;
		try
		{
			// Put parameters string in a bundle if necessary
			if (paramsString != null)
			{
				params = new Bundle();
				params.putString("fields", paramsString);
			}
			
			// Perform Facebook request
			if (params != null)
			{
				data = FBExtensionContext.facebook.request(graphPath, params, this.httpMethod);
			}
			else
			{
				data = FBExtensionContext.facebook.request(graphPath);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			context.dispatchStatusEventAsync(callbackName, e.getMessage());
		}
		
		// Trigger callback if necessary
		if (data != null && callbackName != null)
		{
			context.dispatchStatusEventAsync(callbackName, data);
		}
    }	
}