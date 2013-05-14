package com.freshplanet.ane.AirFacebook;

import com.freshplanet.ane.AirFacebook.functions.InitFunction;
import com.freshplanet.ane.AirFacebook.AirFacebookExtension;

import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;
import android.widget.Button;

public class ExtendAccessTokenActivity extends Activity
{

	private LinearLayout _layout;
	private Button _btn;
	
	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		_layout = new LinearLayout(this.getBaseContext());
		_layout.setOrientation(LinearLayout.VERTICAL);
		
		_btn = new Button(this.getBaseContext());
		_btn.setText("Open Facebook");
		_btn.setOnClickListener(handler_onClickListener);
		
		LinearLayout.LayoutParams __lp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		__lp.topMargin = 5;
		__lp.leftMargin = 5;
		_layout.addView(_btn, __lp);
		this.setContentView(_layout);
		
		AirFacebookExtension.context = new AirFacebookExtensionContext();
	}
	
	View.OnClickListener handler_onClickListener = new View.OnClickListener()
	{
		@Override
		public void onClick(View v)
		{
			Log.d("ABC", "bbc");
			init();
		}
	};
	
	private void init()
	{
		InitFunction __initFun = new InitFunction();
		__initFun.call(AirFacebookExtension.context, null);
	}
}
