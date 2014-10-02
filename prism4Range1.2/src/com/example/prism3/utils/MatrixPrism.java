package com.example.prism3.utils;

public class MatrixPrism {
	/**
	 * Store the model matrix. This matrix is used to move models from object
	 * space (where each model can be thought of being located at the center of
	 * the universe) to world space.
	 */
	private float[] mModelMatrix;

	/**
	 * Store the view matrix. This can be thought of as our camera. This matrix
	 * transforms world space to eye space; it positions things relative to our
	 * eye.
	 */
	private float[] mViewMatrix;

	/**
	 * Store the projection matrix. This is used to project the scene onto a 2D
	 * viewport.
	 */
	private float[] mProjectionMatrix;

	/**
	 * Allocate storage for the final combined matrix. This will be passed into
	 * the shader program.
	 */
	private float[] mMVPMatrix;

	/** A temporary matrix. */
	private float[] mTemporaryMatrix;

	public MatrixPrism(){
		mModelMatrix = new float[16];

		mViewMatrix = new float[16];

		mProjectionMatrix = new float[16];

		mMVPMatrix = new float[16];

		mTemporaryMatrix = new float[16];
	}
	
	public float[] getmModelMatrix() {
		return mModelMatrix;
	}

	public void setmModelMatrix(float[] mModelMatrix) {
		this.mModelMatrix = mModelMatrix;
	}

	public float[] getmViewMatrix() {
		return mViewMatrix;
	}

	public void setmViewMatrix(float[] mViewMatrix) {
		this.mViewMatrix = mViewMatrix;
	}

	public float[] getmProjectionMatrix() {
		return mProjectionMatrix;
	}

	public void setmProjectionMatrix(float[] mProjectionMatrix) {
		this.mProjectionMatrix = mProjectionMatrix;
	}

	public float[] getmMVPMatrix() {
		return mMVPMatrix;
	}

	public void setmMVPMatrix(float[] mMVPMatrix) {
		this.mMVPMatrix = mMVPMatrix;
	}

	public float[] getmTemporaryMatrix() {
		return mTemporaryMatrix;
	}

	public void setmTemporaryMatrix(float[] mTemporaryMatrix) {
		this.mTemporaryMatrix = mTemporaryMatrix;
	}
}
