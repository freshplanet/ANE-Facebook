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

package com.freshplanet.ane.AirFacebook.functions;

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.RequestThread;

public class RequestWithGraphPathFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{	
		// Retrieve graph path
		String graphPath = null;
		try
		{
			graphPath = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Retrieve the parameters
		Bundle parameters = new Bundle();
		FREArray keysArray = (FREArray)arg1[1];
		FREArray valuesArray = (FREArray)arg1[2];
		long arrayLength;
		try
		{
			arrayLength = keysArray.getLength();
			String key;
			String value;
			for (int i = 0; i < arrayLength; i++)
			{
				key =  keysArray.getObjectAt((long)i).getAsString();
				value = valuesArray.getObjectAt((long)i).getAsString();
				parameters.putString(key, value);
			}
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Retrieve HTTP method
		String httpMethod = null;
		try
		{
			httpMethod = arg1[3].getAsString();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Retrieve callback
		String callback = null;
		try
		{
			callback = arg1[4].getAsString();
		}
		catch (Exception e)
		{
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		
		
		// Create a new thread
		RequestThread thread = new RequestThread(arg0, graphPath, parameters, httpMethod, callback);
		thread.start();


		
		return null;
	}
}