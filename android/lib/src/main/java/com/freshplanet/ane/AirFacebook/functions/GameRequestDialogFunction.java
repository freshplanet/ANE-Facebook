package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;
import com.adobe.air.AirFacebookActivityResultCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.widget.GameRequestDialog;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

import java.util.List;

public class GameRequestDialogFunction extends BaseFunction implements AirFacebookActivityResultCallback, FacebookCallback<GameRequestDialog.Result> {

    private String callback;
    private CallbackManager callbackManager;
    AndroidActivityWrapper aaw;

    @Override
    public FREObject call(FREContext context, FREObject[] args) {

        if (!GameRequestDialog.canShow()) {

            AirFacebookExtension.log("ERROR - CANNOT REQUEST!");
            return null;
        }

        int actionType = getIntProperty(args[0], "actionType");
        int filters = getIntProperty(args[0], "filters");
        String data = getStringProperty(args[0], "data");
        String message = getStringProperty(args[0], "message");
        String objectID = getStringProperty(args[0], "objectID");
        String title = getStringProperty(args[0], "title");
        List<String> recipients = getStringListProperty(args[0], "recipients");
        List<String> recipientSuggestions = getStringListProperty(args[0], "recipientSuggestions");
        Boolean frictionless = getBooleanFromFREObject(args[1]); // unused

        callback = getStringFromFREObject(args[2]);

        AirFacebookExtension.log("GameRequestDialogFunction");

        GameRequestContent.Builder builder = new GameRequestContent.Builder();
        if (actionType != 0) builder.setActionType(GameRequestContent.ActionType.values()[actionType - 1]);
        if (data != null) builder.setData(data);
        if (filters != 0) builder.setFilters(GameRequestContent.Filters.values()[filters - 1]);
        if (message != null) builder.setMessage(message);
        if (objectID != null) builder.setObjectId(objectID);
        if (recipients != null) builder.setRecipients(recipients);
        if (recipientSuggestions != null) builder.setSuggestions(recipientSuggestions);
        if (title != null) builder.setTitle(title);

        GameRequestContent gameRequestContent = builder.build();

        callbackManager = CallbackManager.Factory.create();
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
        aaw.addActivityResultListener(this);

        GameRequestDialog gameRequestDialog = new GameRequestDialog(aaw.getActivity());
        gameRequestDialog.registerCallback(callbackManager, this);
        gameRequestDialog.show(gameRequestContent);

        return null;
    }

    @Override
    public void onActivityResult(int i, int i1, Intent intent) {
        callbackManager.onActivityResult(i, i1, intent);
    }

    @Override
    public void onSuccess(GameRequestDialog.Result result) {
        AirFacebookExtension.log("REQUEST_COMPLETE " + result.toString());

        String resultString = "{\"request\":" + result.getRequestId() + ",\"recipients\":" + result.getRequestRecipients() + "}";
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, resultString);
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onCancel() {
        AirFacebookExtension.log("REQUEST_CANCEL!");
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, "OK");
        aaw.removeActivityResultListener(this);
    }

    @Override
    public void onError(FacebookException error) {
        AirFacebookExtension.log("REQUEST_ERROR error: " + error.getMessage());
        AirFacebookExtension.context.dispatchStatusEventAsync(callback, error.getMessage());
        aaw.removeActivityResultListener(this);
    }
}
