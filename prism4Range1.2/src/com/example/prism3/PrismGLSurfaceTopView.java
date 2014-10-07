package com.example.prism3;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class PrismGLSurfaceTopView extends GLSurfaceView 
{	
	private PrismRendererTopView mRenderer;
    
    private float mDensity;
        	
	public PrismGLSurfaceTopView(Context context) 
	{
		super(context);		
	}
	
	public PrismGLSurfaceTopView(Context context, AttributeSet attrs) 
	{
		super(context, attrs);		
	}

	// Hides superclass method.
	public void setRenderer(PrismRendererTopView renderer, float density) 
	{
		mRenderer = renderer;
		mDensity = density;
		super.setRenderer(renderer);
	}
}
