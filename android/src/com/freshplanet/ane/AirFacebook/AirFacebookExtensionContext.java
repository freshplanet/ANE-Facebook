package com.freshplanet.ane.AirFacebook;

import java.util.HashMap;
import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.facebook.login.DefaultAudience;
import com.facebook.login.LoginBehavior;
import com.facebook.share.widget.ShareDialog;
import com.freshplanet.ane.AirFacebook.functions.*;

public class AirFacebookExtensionContext extends FREContext
{
	@Override
	public void dispose()
	{
		AirFacebookExtension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functions = new HashMap<String, FREFunction>();

		// Base API
		functions.put("initFacebook", new InitFacebookFunction());
		functions.put("getAccessToken", new GetAccessTokenFunction());
		functions.put("getProfile", new GetProfileFunction());
		functions.put("logInWithPermissions", new LogInWithPermissionsFunction());
		functions.put("logOut", new LogOutFunction());
		functions.put("requestWithGraphPath", new RequestWithGraphPathFunction());

		// Sharing dialogs
		functions.put("canPresentShareDialog", new CanPresentShareDialogFunction());
		functions.put("shareLinkDialog", new ShareLinkDialogFunction());

		// Invite dialog
		functions.put("canPresentAppInviteDialog", new CanPresentAppInviteDialogFunction());
		functions.put("appInviteDialog", new AppInviteDialogFunction());

		// request dialog
		functions.put("gameRequestDialog", new GameRequestDialogFunction());

		//functions.put("openDeferredAppLink", new OpenDeferredAppLinkFunction());

		// Settings
		functions.put("setLoginBehavior", new SetLoginBehaviorFunction());
		functions.put("setDefaultAudience", new SetDefaultAudienceFunction());
		functions.put("setDefaultShareDialogMode", new SetDefaultShareDialogModeFunction());

		// FB events
		functions.put("activateApp", new ActivateAppFunction());
		functions.put("deactivateApp", new DeactivateAppFunction());
		functions.put("logEvent", new LogEventFunction());

		// Debug
		functions.put("nativeLog", new NativeLogFunction());
		functions.put("setNativeLogEnabled", new SetNativeLogEnabledFunction());

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
