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

package com.freshplanet.natExt.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBRequestThread;

public class RequestWithGraphPathFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{	
		// Retrieve callback name
		String callbackName = null;
		try
		{
			callbackName = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", e.getMessage());
		}
		
		// Retrieve graph path
		String graphPath = null;
		try
		{
			graphPath = arg1[1].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", e.getMessage());
		}
		
		// Retrieve parameters
		String params = null;
		try
		{
			if (arg1.length > 2 && arg1[2] != null)
			{
				params = arg1[2].getAsString();
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", e.getMessage());
		}
		
		// Create a new thread
		FBRequestThread thread = new FBRequestThread(arg0, callbackName, graphPath, params);
		thread.start();
		
		return null;
	}
}