package com.example.prism3.utils;

public class ModelPrism {

	/** This will be used to pass in the texture. */
	private int mTextureUniformHandle;

	/** This will be used to pass in the transformation matrix. */
	private int mMVPMatrixHandle;

	/** This will be used to pass in the model view matrix. */
	private int mMVMatrixHandle;

	/** This will be used to pass in model position information. */
	private int mPositionHandle;

	/** This will be used to pass in model normal information. */
	private int mNormalHandle;

	/** This will be used to pass in model texture coordinate information. */
	private int mTextureCoordinateHandle;

	/** Size of the position data in elements. */
	public static final int mPositionDataSize = 3;

	/** Size of the normal data in elements. */
	public static final int mNormalDataSize = 3;

	/** Size of the texture coordinate data in elements. */
	public static final int mTextureCoordinateDataSize = 2;

	/** This is a handle to our cube shading program. */
	private int mProgramHandle;

	public ModelPrism(){}

	public int getmTextureUniformHandle() {
		return mTextureUniformHandle;
	}

	public void setmTextureUniformHandle(int mTextureUniformHandle) {
		this.mTextureUniformHandle = mTextureUniformHandle;
	}

	public int getmMVPMatrixHandle() {
		return mMVPMatrixHandle;
	}

	public void setmMVPMatrixHandle(int mMVPMatrixHandle) {
		this.mMVPMatrixHandle = mMVPMatrixHandle;
	}

	public int getmMVMatrixHandle() {
		return mMVMatrixHandle;
	}

	public void setmMVMatrixHandle(int mMVMatrixHandle) {
		this.mMVMatrixHandle = mMVMatrixHandle;
	}

	public int getmPositionHandle() {
		return mPositionHandle;
	}

	public void setmPositionHandle(int mPositionHandle) {
		this.mPositionHandle = mPositionHandle;
	}

	public int getmNormalHandle() {
		return mNormalHandle;
	}

	public void setmNormalHandle(int mNormalHandle) {
		this.mNormalHandle = mNormalHandle;
	}

	public int getmTextureCoordinateHandle() {
		return mTextureCoordinateHandle;
	}

	public void setmTextureCoordinateHandle(int mTextureCoordinateHandle) {
		this.mTextureCoordinateHandle = mTextureCoordinateHandle;
	}

	public int getmProgramHandle() {
		return mProgramHandle;
	}

	public void setmProgramHandle(int mProgramHandle) {
		this.mProgramHandle = mProgramHandle;
	}
}
