package com.example.prism3;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;

import android.opengl.GLES20;
import android.opengl.Matrix;

import com.example.prism3.utils.Light;
import com.example.prism3.utils.Maths;
import com.example.prism3.utils.MatrixPrism;
import com.example.prism3.utils.ModelPrism;
import com.example.prism3.utils.SphereModel;

public class MaSphere implements Comparable {

	private Float rayon, x, y, z;

	private SphereModel data;

	private int id;

	public MaSphere(float x, float y, float z, float rayon) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.rayon = rayon;
	}

	/**
	 * Draws a maSphere.
	 */
	public void drawMaSphere(MatrixPrism matrix, Light light, ModelPrism model,
			int texture, SphereModel sphereModel) {

		// Set the active texture unit to texture unit 0.
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);

		// Bind the texture to this unit.
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture);

		// Tell the texture uniform sampler to use this texture in the shader by
		// binding to texture unit 0.
		GLES20.glUniform1i(model.getmTextureUniformHandle(), 0);

		final int stride = (ModelPrism.mPositionDataSize
				+ ModelPrism.mNormalDataSize + ModelPrism.mTextureCoordinateDataSize)
				* SphereModel.mBytesPerFloat;

		for (int i = 0; i < sphereModel.getmTotalNumStrips(); i++) {
			// Pass in the position information
			sphereModel.getmSphereBuffer().get(i).position(0);
			GLES20.glVertexAttribPointer(model.getmPositionHandle(),
					ModelPrism.mPositionDataSize, GLES20.GL_FLOAT, false,
					stride, sphereModel.getmSphereBuffer().get(i));

			// Pass in the normal information
			sphereModel.getmSphereBuffer().get(i)
					.position(ModelPrism.mPositionDataSize);
			GLES20.glVertexAttribPointer(model.getmNormalHandle(),
					ModelPrism.mNormalDataSize, GLES20.GL_FLOAT, false, stride,
					sphereModel.getmSphereBuffer().get(i));

			// Pass in the texture coordinate information
			sphereModel
					.getmSphereBuffer()
					.get(i)
					.position(
							ModelPrism.mPositionDataSize
									+ ModelPrism.mNormalDataSize);
			GLES20.glVertexAttribPointer(model.getmTextureCoordinateHandle(),
					ModelPrism.mTextureCoordinateDataSize, GLES20.GL_FLOAT,
					false, stride, sphereModel.getmSphereBuffer().get(i));

			// This multiplies the view matrix by the model matrix, and stores the
			// result in the MVP matrix
			// (which currently contains model * view).
			Matrix.multiplyMM(matrix.getmMVPMatrix(), 0, matrix.getmViewMatrix(),
					0, matrix.getmModelMatrix(), 0);

			// Pass in the modelview matrix.
			GLES20.glUniformMatrix4fv(model.getmMVMatrixHandle(), 1, false,
					matrix.getmMVPMatrix(), 0);

			// This multiplies the modelview matrix by the projection matrix, and
			// stores the result in the MVP matrix
			// (which now contains model * view * projection).
			Matrix.multiplyMM(matrix.getmTemporaryMatrix(), 0,
					matrix.getmProjectionMatrix(), 0, matrix.getmMVPMatrix(), 0);
			System.arraycopy(matrix.getmTemporaryMatrix(), 0,
					matrix.getmMVPMatrix(), 0, 16);

			// Pass in the combined matrix.
			GLES20.glUniformMatrix4fv(model.getmMVPMatrixHandle(), 1, false,
					matrix.getmMVPMatrix(), 0);

			// Pass in the light position in eye space.
			GLES20.glUniform3f(light.getmLightPosHandle(),
					light.getmLightPosInEyeSpace(0),
					light.getmLightPosInEyeSpace(1),
					light.getmLightPosInEyeSpace(2));

			// Draw the maSphere.
			GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, sphereModel
					.getmSpheres().get(i).length
					/ SphereModel.AMOUNT_OF_NUMBERS_PER_VERTEX_POINT);
		}
	}

	public SphereModel getData() {
		return data;
	}

	public void setData(SphereModel data) {
		this.data = data;
	}

	public float getRayon() {
		return rayon;
	}

	public void setRayon(float rayon) {
		this.rayon = rayon;
	}

	public Float getX() {
		return x;
	}

	public void setX(float x) {
		this.x = x;
	}

	public Float getY() {
		return y;
	}

	public void setY(float y) {
		this.y = y;
	}

	public Float getZ() {
		return z;
	}

	public void setZ(float z) {
		this.z = z;
	}

	public int compareTo(Object o) {
		MaSphere p = (MaSphere) o;
		Float positionThis = z + rayon;
		Float positionP = p.z + p.rayon;
		return positionThis.compareTo(positionP);
	}

	public void setId(int i) {
		this.id = i;
		
	}

	public Integer getId() {
		return id;
	}
}
