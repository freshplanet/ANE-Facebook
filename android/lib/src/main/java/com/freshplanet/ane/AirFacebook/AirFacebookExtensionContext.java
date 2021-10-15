package com.freshplanet.ane.AirFacebook;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.app.Application;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.facebook.AccessToken;
import com.facebook.Profile;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.DefaultAudience;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.share.widget.ShareDialog;
import com.freshplanet.ane.AirFacebook.functions.*;
import com.freshplanet.ane.AirFacebook.utils.FREConversionUtil;

public class AirFacebookExtensionContext extends FREContext {

    /**
     *
     * INTERFACE
     *
     */

    private FREFunction logOut = new FREFunction() {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {

            AirFacebookExtension.log("CloseSessionAndClearTokenInformationFunction");

            AccessToken.setCurrentAccessToken(null);
            Profile.setCurrentProfile(null);
            LoginManager.getInstance().logOut();

            return null;
        }
    };

    private FREFunction nativeLog = new FREFunction() {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {

            String message = FREConversionUtil.toString(args[0]);
            AirFacebookExtension.nativeLog(message, "AS3");

            return null;
        }
    };

    private FREFunction setNativeLogEnabled = new FREFunction() {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {

            AirFacebookExtension.nativeLogEnabled = FREConversionUtil.toBoolean(args[0]);
            return null;
        }
    };

    private FREFunction activateApp = new FREFunction() {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {

            Activity activity = ctx.getActivity();
            Application application = activity.getApplication();
            AppEventsLogger.activateApp(application);

            return null;
        }
    };

    private FREFunction deactivateApp = new FREFunction() {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {
        	// now works automatically
            return null;
        }
    };

    /**
     *
     * FRECONTEXT SETUP
     *
     */

	@Override
	public void dispose() {
		AirFacebookExtension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions() {

		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();

		// Base API
		functions.put("initFacebook", new InitFacebookFunction());
		functions.put("getAccessToken", new GetAccessTokenFunction());
		functions.put("getProfile", new GetProfileFunction());
		functions.put("logInWithPermissions", new LogInWithPermissionsFunction());
		functions.put("logOut", logOut);
		functions.put("requestWithGraphPath", new RequestWithGraphPathFunction());

		// Sharing dialogs
		functions.put("canPresentShareDialog", new CanPresentShareDialogFunction());
		functions.put("shareLinkDialog", new ShareLinkDialogFunction());

		// request dialog
		functions.put("gameRequestDialog", new GameRequestDialogFunction());

		//functions.put("openDeferredAppLink", new OpenDeferredAppLinkFunction());

		// Settings
		functions.put("setLoginBehavior", new SetLoginBehaviorFunction());
		functions.put("setDefaultAudience", new SetDefaultAudienceFunction());
		functions.put("setDefaultShareDialogMode", new SetDefaultShareDialogModeFunction());

		// FB events
		functions.put("activateApp", activateApp);
		functions.put("deactivateApp", deactivateApp);
		functions.put("logEvent", new LogEventFunction());

		// Debug
		functions.put("nativeLog", nativeLog);
		functions.put("setNativeLogEnabled", setNativeLogEnabled);

		return functions;	
	}
	
	private String appID;
	private DefaultAudience defaultAudience = DefaultAudience.FRIENDS;
	private ShareDialog.Mode defaultShareDialogMode = ShareDialog.Mode.AUTOMATIC;
	private LoginBehavior loginBehavior = LoginBehavior.NATIVE_WITH_FALLBACK;

	public String getAppID() {
		return appID;
	}
	public void setAppID(String appID) {
		this.appID = appID;
	}

	public DefaultAudience getDefaultAudience() {
		return defaultAudience;
	}

	public void setDefaultAudience(DefaultAudience defaultAudience) {
		this.defaultAudience = defaultAudience;
	}

	public ShareDialog.Mode getDefaultShareDialogMode() {
		return defaultShareDialogMode;
	}

	public void setDefaultShareDialogMode(ShareDialog.Mode defaultShareDialogMode) {
		this.defaultShareDialogMode = defaultShareDialogMode;
	}

	public LoginBehavior getLoginBehavior() {
		return loginBehavior;
	}

	public void setLoginBehavior(LoginBehavior loginBehavior) {
		this.loginBehavior = loginBehavior;
	}
}
