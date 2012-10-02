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

import org.json.JSONArray;
import org.json.JSONObject;

import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.natExt.FBRequestThread;

public class DeleteInvitesFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve object ids
		FREArray objectIds = (FREArray)arg1[0];
		long arrayLength = 0;
		try
		{
			arrayLength = objectIds.getLength();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
		}
		
		// Create JSON array
		JSONArray batch_array = new JSONArray();
		for (int i = 0; i < arrayLength; i++)
		{
			try
			{
				String requestPath = objectIds.getObjectAt(i).getAsString();
				JSONObject deleteRequest = new JSONObject();
				deleteRequest.put("method", "DELETE");
				deleteRequest.put("relative_url", requestPath);
				batch_array.put(deleteRequest);
			}
			catch (Exception e)
			{
				e.printStackTrace();
				arg0.dispatchStatusEventAsync("LOGGING", "Error - " + e.getMessage());
			}
		}
		
		// Prepare parameters bundle
		Bundle params = new Bundle();
		params.putString("batch", batch_array.toString());
		
		// Create new thread
		FBRequestThread thread = new FBRequestThread(arg0, "deleteInvites", "me", params, "POST");
		thread.start();
		
		return null;
	}
}