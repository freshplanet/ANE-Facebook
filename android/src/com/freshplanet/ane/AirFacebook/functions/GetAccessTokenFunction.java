package com.freshplanet.ane.AirFacebook.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.AccessToken;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

public class GetAccessTokenFunction extends BaseFunction
{
	public FREObject call(FREContext context, FREObject[] args)
	{
		super.call(context, args);

		AirFacebookExtension.log("GetAccessTokenFunction");

		AccessToken accessToken = AccessToken.getCurrentAccessToken();
		if(accessToken != null){

			try {
				FREObject result = FREObject.newObject("com.freshplanet.ane.AirFacebook.FBAccessToken", null);
				result.setProperty("appID", FREObject.newObject(accessToken.getApplicationId()));
				result.setProperty("declinedPermissions", getFREArrayFromSet(accessToken.getDeclinedPermissions()));
				result.setProperty("expirationDate", FREObject.newObject((double) (accessToken.getExpires().getTime() / 1000)));
				result.setProperty("permissions", getFREArrayFromSet(accessToken.getPermissions()));
				result.setProperty("refreshDate", FREObject.newObject((double)(accessToken.getLastRefresh().getTime() / 1000)));
				result.setProperty("tokenString", FREObject.newObject(accessToken.getToken()));
				result.setProperty("userID", FREObject.newObject(accessToken.getUserId()));
				return result;
			} catch (Exception e) {
				e.printStackTrace();
				AirFacebookExtension.log("GetAccessTokenFunction ERROR " + e.getMessage());
				return null;
			}
		}

		return null;
	}
}