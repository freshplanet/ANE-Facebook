package com.freshplanet.ane.AirFacebook.functions;

import android.content.Intent;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.share.model.GameRequestContent;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;
import com.freshplanet.ane.AirFacebook.GameRequestActivity;

import java.util.List;

public class GameRequestDialogFunction extends BaseFunction implements FREFunction
{
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        int actionType = getIntProperty(args[0], "actionType");
        String data = getStringProperty(args[0], "data");
        int filters = getIntProperty(args[0], "filters");
        String message = getStringProperty(args[0], "message");
        String objectID = getStringProperty(args[0], "objectID");
        List<String> recipients = getStringListProperty(args[0], "recipients");
        List<String> recipientSuggestions = getStringListProperty(args[0], "recipientSuggestions");
        String title = getStringProperty(args[0], "title");

        Boolean frictionless = getBooleanFromFREObject(args[1]); // unused
        String callback = getStringFromFREObject(args[2]);

        AirFacebookExtension.log("GameRequestDialogFunction");

        GameRequestContent.Builder builder = new GameRequestContent.Builder();
        if(actionType != 0) builder.setActionType(GameRequestContent.ActionType.values()[actionType - 1]);
        if(data != null) builder.setData(data);
        if(filters != 0) builder.setFilters(GameRequestContent.Filters.values()[filters - 1]);
        if(message != null) builder.setMessage(message);
        if(objectID != null) builder.setObjectId(objectID);
        if(recipients != null) builder.setRecipients(recipients);
        if(recipientSuggestions != null) builder.setSuggestions(recipientSuggestions);
        if(title != null) builder.setTitle(title);

        GameRequestContent content = builder.build();

        Intent i = new Intent(context.getActivity().getApplicationContext(), GameRequestActivity.class);
        i.putExtra(GameRequestActivity.extraPrefix + ".callback", callback);
        i.putExtra(GameRequestActivity.extraPrefix + ".content", content);
        context.getActivity().startActivity(i);

        return null;

    }
}
