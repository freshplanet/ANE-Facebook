
package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.AppEventsLogger;
import com.facebook.AppLinkData;

public class OpenDeferredAppLinkFunction extends BaseFunction
{
	@Override
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

   	 /* Facebook Docs
   	  * https://developers.facebook.com/docs/ads-for-apps/mobile-app-ads-engagement#measure
   	  */
		AppLinkData.fetchDeferredAppLinkData(context.getActivity(), new AppLinkData.CompletionHandler() {
			@Override
			public void onDeferredAppLinkDataFetched(AppLinkData appLinkData) {
				
			// TODO: Implement - 12/12/2014 - Nigam

			/* NOTE: Per post in stackoverflow, this doesn't work in Android
			
			http://stackoverflow.com/questions/26695003/how-to-get-facebook-app-link-if-app-wasnt-installed
			"As of Dec 2, 2014 facebook deferred app links are broken on Android.
			I can get my app links to work when the app is already installed, but
			when the app is NOT already installed the app link is never sent to the app after it's installed.
			I'm in touch with facebook, I'll post any updates here."
			 
			 */

			}
		});
		
		return null;
	}
}
