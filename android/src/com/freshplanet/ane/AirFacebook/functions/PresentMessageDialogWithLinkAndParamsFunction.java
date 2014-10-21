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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.facebook.widget.FacebookDialog;

public class PresentMessageDialogWithLinkAndParamsFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);
		
		String url = getStringFromFREObject(args[0]);
		String name = getStringFromFREObject(args[1]);
		String caption = getStringFromFREObject(args[2]);
		String description = getStringFromFREObject(args[3]);
		String pictureUrl = getStringFromFREObject(args[4]);

		FacebookDialog.MessageDialogBuilder builder = new FacebookDialog.MessageDialogBuilder(context.getActivity())
		    .setLink(url)
		    .setName(name)
		    .setCaption(caption)
		    .setDescription(description)
		    .setPicture(pictureUrl);

		if (builder.canPresent()) 
		{
			FacebookDialog dialog = builder.build();
			dialog.present();
			// TODO: Investigate why Messenger does not get triggered
		}
		
		return null;
	}
}