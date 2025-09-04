package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;
import android.net.Uri;
import com.adobe.air.AirFacebookActivityResultCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.ShareApi;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

import java.util.List;

public class ShareLinkDialogFunction extends BaseFunction implements AirFacebookActivityResultCallback, FacebookCallback<Sharer.Result> {

    private String callback;
    private CallbackManager callbackManager;
    AndroidActivityWrapper aaw;

    @Override
	public FREObject call(FREContext context, FREObject[] args) {

		// Retrieve callback
		String contentUrl = getStringProperty(args[0], "contentUrl");
		String placeId = getStringProperty(args[0], "placeId");
		String ref = getStringProperty(args[0], "ref");
		String contentTitle = getStringProperty(args[0], "contentTitle");
		String contentDescription = getStringProperty(args[0], "contentDescription");
		String imageUrl = getStringProperty(args[0], "imageUrl");
        List<String> peopleIds = getStringListProperty(args[0], "peopleIds");

        callback = getStringFromFREObject(args[1]);

		AirFacebookExtension.log("ShareLinkDialogFunction");

		ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
		if (contentUrl != null) builder.setContentUrl(Uri.parse(contentUrl));
		if (peopleIds != null) builder.setPeopleIds(peopleIds);
		if (placeId != null) builder.setPlaceId(placeId);
		if (ref != null) builder.setRef(ref);
		// if (contentTitle != null) builder.setContentTitle(contentTitle);
		// if (imageUrl != null) builder.setImageUrl(Uri.parse(imageUrl));
		// if (contentDescription != null) builder.setContentDescription(contentDescription);
		ShareLinkContent shareLinkContent = builder.build();

        callbackManager = CallbackManager.Factory.create();
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
        aaw.addActivityResultListener(this);

        ShareDialog shareDialog = new ShareDialog(aaw.getActivity());
        shareDialog.registerCallback(callbackManager, this);

        if (shareDialog.canShow(shareLinkContent, AirFacebookExtension.context.getDefaultShareDialogMode()))
            shareDialog.show(shareLinkContent, AirFacebookExtension.context.getDefaultShareDialogMode());
        else
            AirFacebookExtension.log("ERROR - CANNOT SHARE!");

		return null;
	}

    @Override
    public void onActivityResult(int i, int i1, Intent intent) {
        callbackManager.onActivityResult(i, i1, intent);
    }

    @Override
    public void onSuccess(Sharer.Result result) {

        AirFacebookExtension.log("SUCCESS! " + result.toString());
        AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_SUCCESS_" + callback, "{}");
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onCancel() {

        AirFacebookExtension.log("CANCELLED!");
        AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_CANCELLED_" + callback, "{}");
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onError(FacebookException error) {

        AirFacebookExtension.log("ERROR!" + error.getMessage());
        AirFacebookExtension.context.dispatchStatusEventAsync("SHARE_ERROR_" + callback, "{}");
        aaw.removeActivityResultListener(this);
    }
}