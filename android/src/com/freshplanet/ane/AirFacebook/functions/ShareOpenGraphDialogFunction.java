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

import android.content.Intent;
import android.os.Bundle;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.ShareOGActivity;

public class ShareOpenGraphDialogFunction implements FREFunction
{
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve callback
		String callback = null;
		String actionType = null;
		Bundle actionParams = new Bundle();
		String previewProperty = null;
		try {
			actionType		= arg1[0] == null ? null : arg1[0].getAsString();
			
			FREArray keysArray = (FREArray)arg1[1];
			FREArray valuesArray = (FREArray)arg1[2];
			long arrayLength;
			arrayLength = keysArray.getLength();
			String key;
			String value;
			for (int i = 0; i < arrayLength; i++)
			{
				key =  keysArray.getObjectAt((long)i).getAsString();
				value = valuesArray.getObjectAt((long)i).getAsString();
				actionParams.putString(key, value);
			}
			
			previewProperty	= arg1[3] == null ? null : arg1[3].getAsString();
			callback		= arg1[6] == null ? null : arg1[6].getAsString();
		} catch (Exception e) {
			AirFacebookExtension.log("ERROR - " + e.getMessage());
		}
		
		// Start dialog activity
		Intent i = new Intent(arg0.getActivity().getApplicationContext(), ShareOGActivity.class);
		i.putExtra(ShareOGActivity.extraPrefix+".actionType", actionType);
		i.putExtra(ShareOGActivity.extraPrefix+".actionParams", actionParams);
		i.putExtra(ShareOGActivity.extraPrefix+".previewProperty", previewProperty);
		i.putExtra(ShareOGActivity.extraPrefix+".callback", callback);
		arg0.getActivity().startActivity(i);
		
		return null;
	}
}