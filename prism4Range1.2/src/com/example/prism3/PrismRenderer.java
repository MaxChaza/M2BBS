package com.example.prism3;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Stack;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import android.util.DisplayMetrics;

import com.example.prism3.utils.Light;
import com.example.prism3.utils.MatrixPrism;
import com.example.prism3.utils.ModelPrism;
import com.example.prism3.utils.RawResourceReader;
import com.example.prism3.utils.ShaderHelper;
import com.example.prism3.utils.SphereModel;
import com.example.prism3.utils.TextureHelper;

/**
 * This class implements our custom renderer. Note that the GL10 parameter
 * passed in is unused for OpenGL ES 2.0 renderers -- the static class GLES20 is
 * used instead.
 */
public class PrismRenderer implements GLSurfaceView.Renderer {

	// These still work without volatile, but refreshes are not guaranteed to
	// happen.
	public volatile float mDeltaX;
	public volatile float mDeltaY;

	/** Used for debug logs. */
	private static final String TAG = "LessonSixRenderer";

	private final int nbSpheres;
	private final float nbDivisions;
	private final float tailleSpheres;

	// private final float MAX_RAYON = 0.2f;
	// private final float MIN_RAYON = 0.04f;

	private final Context mActivityContext;
	private final PrismActivity activity;

	/** These are handles to our texture data. */
	private int metalTextureCube;
	private int metalTextureSphere;
	private int metalTextureSphereCible;
	private int metalTextureSphereTouche;
	private int textureCylindre;

	private Cylinder cylindreIn, cylindre;
	private Light light;
	private MatrixPrism matrix;
	private ModelPrism model;
	private Cube cube;
	private MaSphere cibleCoords;
	private Set<MaSphere> listCoords = new HashSet<MaSphere>();
	private Set<MaSphere> listCollisions = new HashSet<MaSphere>();
	private ArrayList<Integer> listZones = new ArrayList<Integer>();

	List<MaSphere> listLogSpheres;
	private boolean cibleIsTouch;
	private SphereModel sphereModel;

	private Set<MaSphere> enCoursCibleList = new HashSet<MaSphere>();
	private Set<MaSphere> enCoursList = new HashSet<MaSphere>();

	private Set<MaSphere> listCollisionsDepart = new HashSet<MaSphere>();
	private Stack<Set<MaSphere>> allPreviousList = new Stack<Set<MaSphere>>();
	private Stack<Set<MaSphere>> allPreviousCibleList = new Stack<Set<MaSphere>>();

	private Set<MaSphere> globalList = new HashSet<MaSphere>();
	private HashSet<MaSphere> backList = new HashSet<MaSphere>();
	private HashSet<MaSphere> frontList = new HashSet<MaSphere>();
	private int metalTextureSphereCibleBack;
	private int metalTextureSphereCibleFront;
	private int metalTextureSphereToucheBack;

	private final Lock accessListLock = new ReentrantLock();

	public Lock getAccessListLock() {
		return accessListLock;
	}

	private String typeSelection = "dichotomie";

	private boolean created = true;

	/**
	 * Initialize the model data.
	 */
	public PrismRenderer(final PrismActivity act, int nbSph, int divisions,
			float taille) {
		activity = act;
		mActivityContext = activity.getApplicationContext();
		light = new Light();
		model = new ModelPrism();
		matrix = new MatrixPrism();
		nbSpheres = nbSph;
		nbDivisions = divisions;
		tailleSpheres = taille;
		cube = new Cube(0.0f, 0.0f, 0.0f, 0, 0);
		for (int i = 0; i < nbDivisions * nbDivisions * nbDivisions; i++)
			listZones.add(i);

		createTest();

		// Le bord d'une sphere ne dépasse pas sa zone
		// if (nbDivisions == 1) {
		// /******************************************************
		// * Random positioning
		// */
		//
		// float randomRadius = (float) (Math.random()
		// * (MAX_RAYON - MIN_RAYON) + MIN_RAYON);
		// float randomX = (float) (Math.random()
		// * ((1f - randomRadius) + (1f - randomRadius)) - (1f - randomRadius));
		// float randomY = (float) (Math.random()
		// * ((1.5f - randomRadius) + (1.5f - randomRadius)) - (1.5f -
		// randomRadius));
		// float randomZ = (float) (Math.random()
		// * ((1.5f - randomRadius) + (1.2f - randomRadius)) - (1.2f -
		// randomRadius));
		//
		// cibleCoords.add(new MaSphere(randomX, randomY, randomZ,
		// randomRadius));
		//
		// for (int i = 0; i < nbSpheres; i++) {
		//
		// randomRadius = (float) (Math.random() * (MAX_RAYON - MIN_RAYON) +
		// MIN_RAYON);
		// randomX = (float) (Math.random()
		// * ((1f - randomRadius) + (1f - randomRadius)) - (1f - randomRadius));
		// randomY = (float) (Math.random()
		// * ((1.5f - randomRadius) + (1.5f - randomRadius)) - (1.5f -
		// randomRadius));
		// randomZ = (float) (Math.random()
		// * ((1.5f - randomRadius) + (1.2f - randomRadius)) - (1.2f -
		// randomRadius));
		//
		// sphere = new MaSphere(randomX, randomY, randomZ, randomRadius);
		// listCoords.add(sphere);
		// }
		// } else {
		// float xFac = 2f / nbDivisions;
		// float yFac = 3f / nbDivisions;
		// float zFac = 3f / nbDivisions;
		//
		// for (float z = -1.5f; z < 1.5; z += zFac) {
		// for (float x = -1f; x < 1; x += xFac) {
		// for (float y = -1.5f; y < 1.5; y += yFac) {
		// /******************************************************
		// * Random positioning with division
		// */
		// float ux = x + xFac;
		// float uy = y + yFac;
		// float uz = z + zFac;
		//
		// float randomRadius = (float) (Math.random()
		// * (MAX_RAYON - MIN_RAYON) + MIN_RAYON);
		// float randomX = (float) (Math.random()
		// * ((x + randomRadius) - (ux - randomRadius)) + (ux - randomRadius));
		// float randomY = (float) (Math.random()
		// * ((y + randomRadius) - (uy - randomRadius)) + (uy - randomRadius));
		// float randomZ = (float) (Math.random()
		// * ((z + randomRadius) - (uz - randomRadius)) + (uz - randomRadius));
		//
		// cibleCoords.add(new MaSphere(randomX, randomY, randomZ,
		// randomRadius));
		//
		// for (int i = 0; i < nbSpheres; i++) {
		//
		// randomRadius = (float) (Math.random()
		// * (MAX_RAYON - MIN_RAYON) + MIN_RAYON);
		//
		// randomX = (float) (Math.random()
		// * ((x + randomRadius) - (ux - randomRadius)) + (ux - randomRadius));
		// randomY = (float) (Math.random()
		// * ((y + randomRadius) - (uy - randomRadius)) + (uy - randomRadius));
		// randomZ = (float) (Math.random()
		// * ((z + randomRadius) - (uz - randomRadius)) + (uz - randomRadius));
		//
		// sphere = new MaSphere(randomX, randomY, randomZ,
		// randomRadius);
		// listCoords.add(sphere);
		// }
		// }
		// }
		// }
		// }
	}

	public void createTest() {

		cylindre = new Cylinder(0f, 0.5f, 0f, 0.05f, 3f);
		cylindreIn = new Cylinder(0f, 0.5f, 0f, 0.05f, 3f);
		listCoords = new HashSet<MaSphere>();
		listCollisions = new HashSet<MaSphere>();
		enCoursCibleList = new HashSet<MaSphere>();
		enCoursList = new HashSet<MaSphere>();

		allPreviousList = new Stack<Set<MaSphere>>();
		allPreviousCibleList = new Stack<Set<MaSphere>>();

		globalList = new HashSet<MaSphere>();
		backList = new HashSet<MaSphere>();
		frontList = new HashSet<MaSphere>();

		sphereModel = new SphereModel(4);
		listCollisions = new HashSet<>();

		cibleIsTouch = false;
		MaSphere sphere;

		if (nbDivisions == 1) {
			/******************************************************
			 * Random positioning
			 */

			float randomX = (float) (Math.random()
					* ((1f - tailleSpheres) + (1f - tailleSpheres)) - (1f - tailleSpheres));
			float randomY = (float) (Math.random()
					* ((1.5f - tailleSpheres) + (1.5f - tailleSpheres)) - (1.5f - tailleSpheres));
			float randomZ = (float) (Math.random()
					* ((1.5f - tailleSpheres) + (1.2f - tailleSpheres)) - (1.2f - tailleSpheres));

			cibleCoords = new MaSphere(randomX, randomY, randomZ, tailleSpheres);

			for (int i = 0; i < nbSpheres; i++) {

				randomX = (float) (Math.random()
						* ((1f - tailleSpheres) + (1f - tailleSpheres)) - (1f - tailleSpheres));
				randomY = (float) (Math.random()
						* ((1.5f - tailleSpheres) + (1.5f - tailleSpheres)) - (1.5f - tailleSpheres));
				randomZ = (float) (Math.random()
						* ((1.5f - tailleSpheres) + (1.2f - tailleSpheres)) - (1.2f - tailleSpheres));

				sphere = new MaSphere(randomX, randomY, randomZ, tailleSpheres);
				listCoords.add(sphere);
			}
			listZones.remove(0);
		} else {
			float xFac = 2f / nbDivisions;
			float yFac = 3f / nbDivisions;
			float zFac = 3f / nbDivisions;

			int randomCibleZone = (int) (Math.random()
					* (listZones.size() - 1 - 0) + 0);

			int zone = 0;
			for (float z = -1.5f; z < 1.5; z += zFac) {
				for (float x = -1f; x < 1; x += xFac) {
					for (float y = -1.5f; y < 1.5; y += yFac) {
						/******************************************************
						 * Random positioning with division
						 */
						float ux = x + xFac;
						float uy = y + yFac;
						float uz = z + zFac;

						float tailleSpheresXNeg = 0;
						float tailleSpheresXPos = 0;
						float tailleSpheresYNeg = 0;
						float tailleSpheresYPos = 0;
						float tailleSpheresZNeg = 0;
						float tailleSpheresZPos = 0;
						float randomX, randomY, randomZ;

						if (zone == listZones.get(randomCibleZone)) {
							if (x == -1f)
								tailleSpheresXNeg = tailleSpheres;
							else if (x == -1f + (xFac * (nbDivisions - 1)))
								tailleSpheresXPos = tailleSpheres;

							if (y == -1.5f)
								tailleSpheresYNeg = tailleSpheres;
							else if (y == -1.5f + (yFac * (nbDivisions - 1)))
								tailleSpheresYPos = tailleSpheres;

							if (z == -1.5f)
								tailleSpheresZNeg = tailleSpheres;
							else if (z == -1.5f + (zFac * (nbDivisions - 1)))
								tailleSpheresZPos = tailleSpheres;

							randomX = (float) (Math.random()
									* ((x + tailleSpheresXNeg) - (ux - tailleSpheresXPos)) + (ux - tailleSpheresXPos));
							randomY = (float) (Math.random()
									* ((y + tailleSpheresYNeg) - (uy - tailleSpheresYPos)) + (uy - tailleSpheresYPos));
							randomZ = (float) (Math.random()
									* ((z + tailleSpheresZNeg) - (uz - tailleSpheresZPos)) + (uz - tailleSpheresZPos));

							cibleCoords = new MaSphere(randomX, randomY,
									randomZ, tailleSpheres);

						}

						for (int i = 0; i < nbSpheres; i++) {

							tailleSpheresXNeg = 0;
							tailleSpheresXPos = 0;
							if (x == -1f)
								tailleSpheresXNeg = tailleSpheres;
							else if (x == -1f + (xFac * (nbDivisions - 1)))
								tailleSpheresXPos = tailleSpheres;

							tailleSpheresYNeg = 0;
							tailleSpheresYPos = 0;
							if (y == -1.5f)
								tailleSpheresYNeg = tailleSpheres;
							else if (y == -1.5f + (yFac * (nbDivisions - 1)))
								tailleSpheresYPos = tailleSpheres;

							tailleSpheresZNeg = 0;
							tailleSpheresZPos = 0;
							if (z == -1.5f)
								tailleSpheresZNeg = tailleSpheres;
							else if (z == -1.5f + (zFac * (nbDivisions - 1)))
								tailleSpheresZPos = tailleSpheres;

							randomX = (float) (Math.random()
									* ((x + tailleSpheresXNeg) - (ux - tailleSpheresXPos)) + (ux - tailleSpheresXPos));
							randomY = (float) (Math.random()
									* ((y + tailleSpheresYNeg) - (uy - tailleSpheresYPos)) + (uy - tailleSpheresYPos));
							randomZ = (float) (Math.random()
									* ((z + tailleSpheresZNeg) - (uz - tailleSpheresZPos)) + (uz - tailleSpheresZPos));

							sphere = new MaSphere(randomX, randomY, randomZ,
									tailleSpheres);
							listCoords.add(sphere);
						}
						zone++;
					}
				}
			}

			listZones.remove(randomCibleZone);
		}
		globalList.add(cibleCoords);
		globalList.addAll(listCoords);

		listLogSpheres = new ArrayList(globalList);
		Collections.sort(listLogSpheres);
		int id = 0;
		for (MaSphere aSphere : listLogSpheres) {
			aSphere.setId(id);
			id++;
		}

		globalList = new HashSet<MaSphere>();

		if (!created)
			activity.getmGLSurfaceView().requestRender();

		created = true;
	}

	public static int loadShader(int type, String shaderCode) {

		// create a vertex shader type (GLES20.GL_VERTEX_SHADER)
		// or a fragment shader type (GLES20.GL_FRAGMENT_SHADER)
		int shader = GLES20.glCreateShader(type);

		// add the source code to the shader and compile it
		GLES20.glShaderSource(shader, shaderCode);
		GLES20.glCompileShader(shader);

		return shader;
	}

	@Override
	public void onSurfaceCreated(GL10 glUnused, EGLConfig config) {

		// Set the background clear color to black.
		GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

		// Use culling to remove back faces.
		// GLES20.glEnable(GLES20.GL_CULL_FACE);

		// Enable depth testing
		GLES20.glEnable(GLES20.GL_DEPTH_TEST);

		// The below glEnable() call is a holdover from OpenGL ES 1, and is not
		// needed in OpenGL ES 2.
		// Enable texture mapping
		// GLES20.glEnable(GLES20.GL_TEXTURE_2D);

		// Position the eye in front of the origin.
		final float eyeX = 0.0f;
		final float eyeY = 0.0f;
		final float eyeZ = -3f;

		// We are looking toward the distance
		final float lookX = 0.0f;
		final float lookY = 0.0f;
		final float lookZ = 0.0f;

		// Set our up vector. This is where our head would be pointing were we
		// holding the camera.
		final float upX = 0.0f;
		final float upY = 1.0f;
		final float upZ = 0.0f;

		// Set the view matrix. This matrix can be said to represent the camera
		// position.
		// NOTE: In OpenGL 1, a ModelView matrix is used, which is a combination
		// of a model and
		// view matrix. In OpenGL 2, we can keep track of these matrices
		// separately if we choose.
		Matrix.setLookAtM(matrix.getmViewMatrix(), 0, eyeX, eyeY, eyeZ, lookX,
				lookY, lookZ, upX, upY, upZ);

		final String vertexShader = RawResourceReader
				.readTextFileFromRawResource(mActivityContext,
						R.raw.per_pixel_vertex_shader_tex_and_light);
		final String fragmentShader = RawResourceReader
				.readTextFileFromRawResource(mActivityContext,
						R.raw.per_pixel_fragment_shader_tex_and_light);

		final int vertexShaderHandle = ShaderHelper.compileShader(
				GLES20.GL_VERTEX_SHADER, vertexShader);
		final int fragmentShaderHandle = ShaderHelper.compileShader(
				GLES20.GL_FRAGMENT_SHADER, fragmentShader);

		int mProgramHandl = ShaderHelper.createAndLinkProgram(
				vertexShaderHandle, fragmentShaderHandle, new String[] {
						"a_Position", "a_Normal", "a_TexCoordinate" });
		model.setmProgramHandle(mProgramHandl);

		// Define a simple shader program for our point.
		final String pointVertexShader = RawResourceReader
				.readTextFileFromRawResource(mActivityContext,
						R.raw.point_vertex_shader);
		final String pointFragmentShader = RawResourceReader
				.readTextFileFromRawResource(mActivityContext,
						R.raw.point_fragment_shader);

		final int pointVertexShaderHandle = ShaderHelper.compileShader(
				GLES20.GL_VERTEX_SHADER, pointVertexShader);
		final int pointFragmentShaderHandle = ShaderHelper.compileShader(
				GLES20.GL_FRAGMENT_SHADER, pointFragmentShader);
		int mPointProgramHandle = ShaderHelper.createAndLinkProgram(
				pointVertexShaderHandle, pointFragmentShaderHandle,
				new String[] { "a_Position" });
		light.setMPointProgramHandle(mPointProgramHandle);

		// Load the texture
		metalTextureSphere = TextureHelper.loadTexture(mActivityContext,
				R.drawable.metal_texture_spheret);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureSphereCible = TextureHelper.loadTexture(mActivityContext,
				R.drawable.metal_texture_sphere_cible);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureSphereCibleBack = TextureHelper.loadTexture(
				mActivityContext, R.drawable.metal_texture_sphere_cible_back);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureSphereCibleFront = TextureHelper.loadTexture(
				mActivityContext, R.drawable.metal_texture_sphere_cible_front);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureSphereTouche = TextureHelper.loadTexture(mActivityContext,
				R.drawable.metal_texture_sphere_touche);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureSphereToucheBack = TextureHelper.loadTexture(
				mActivityContext, R.drawable.metal_texture_sphere_touche_back);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		metalTextureCube = TextureHelper.loadTexture(mActivityContext,
				R.drawable.brick);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

		textureCylindre = TextureHelper.loadTexture(mActivityContext,
				R.drawable.iconverteautransparent);
		GLES20.glGenerateMipmap(GLES20.GL_TEXTURE_2D);

	}

	@Override
	public void onSurfaceChanged(GL10 glUnused, int width, int height) {
		// Set the OpenGL viewport to the same size as the surface.
		GLES20.glViewport(0, 0, width, height);

		// Create a new perspective projection matrix. The height will stay the
		// same
		// while the width will vary as per aspect ratio.
		final float ratio = (float) width / height;
		final float left = -ratio;
		final float right = ratio;
		final float bottom = -1.0f;
		final float top = 1.0f;
		final float near = 1.0f;
		final float far = 1000.0f;

		Matrix.frustumM(matrix.getmProjectionMatrix(), 0, left, right, bottom,
				top, near, far);
	}

	@Override
	public void onDrawFrame(GL10 glUnused) {
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
		// Set our per-vertex lighting program.
		GLES20.glUseProgram(model.getmProgramHandle());

		// Set program handles for cube drawing.
		model.setmMVPMatrixHandle(GLES20.glGetUniformLocation(
				model.getmProgramHandle(), "u_MVPMatrix"));
		model.setmMVMatrixHandle(GLES20.glGetUniformLocation(
				model.getmProgramHandle(), "u_MVMatrix"));
		light.setmLightPosHandle(GLES20.glGetUniformLocation(
				model.getmProgramHandle(), "u_LightPos"));
		model.setmTextureUniformHandle(GLES20.glGetUniformLocation(
				model.getmProgramHandle(), "u_Texture"));
		model.setmPositionHandle(GLES20.glGetAttribLocation(
				model.getmProgramHandle(), "a_Position"));
		model.setmNormalHandle(GLES20.glGetAttribLocation(
				model.getmProgramHandle(), "a_Normal"));
		model.setmTextureCoordinateHandle(GLES20.glGetAttribLocation(
				model.getmProgramHandle(), "a_TexCoordinate"));

		// Calculate position of the light. Rotate and then push into the
		// distance.
		Matrix.setIdentityM(light.getmLightModelMatrix(), 0);
		Matrix.translateM(light.getmLightModelMatrix(), 0, 0.0f, 0.0f, 0.0f);

		Matrix.multiplyMV(light.getmLightPosInWorldSpace(), 0,
				light.getmLightModelMatrix(), 0,
				light.getmLightPosInModelSpace(), 0);
		Matrix.multiplyMV(light.getmLightPosInEyeSpace(), 0,
				matrix.getmViewMatrix(), 0, light.getmLightPosInWorldSpace(), 0);

		GLES20.glEnableVertexAttribArray(model.getmPositionHandle());
		// Light!!!
		GLES20.glEnableVertexAttribArray(model.getmNormalHandle());

		GLES20.glEnableVertexAttribArray(model.getmTextureCoordinateHandle());

		/*************************************************************************************
		 * Draw a cube. Translate the cube into the screen.
		 */
		Matrix.setIdentityM(matrix.getmModelMatrix(), 0);
		Matrix.translateM(matrix.getmModelMatrix(), 0, 0, 0, 0);
		cube.drawCube(matrix, light, model, metalTextureCube);

		/*************************************************************************************
		 * Draw spheres. Translate the spheres into the screen.
		 */
		if (cylindre.isVisible()) {

			MaSphere aSphere;

			// // Put position of all Spheres
			translateAndScaleASphere(cibleCoords.getX(), cibleCoords.getY(),
					cibleCoords.getZ(), cibleCoords.getRayon());

			cibleCoords.drawMaSphere(matrix, light, model,
					metalTextureSphereCible, sphereModel);

			HashSet<MaSphere> buff = new HashSet<>();
			buff.addAll(listCoords);
			buff.removeAll(listCollisions);

			// // Put position of all Spheres
			for (MaSphere co : listCollisions) {
				translateAndScaleASphere(co.getX(), co.getY(), co.getZ(),
						co.getRayon());

				GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
						GLES20.GL_ONE_MINUS_SRC_ALPHA);
				GLES20.glEnable(GLES20.GL_BLEND);
				co.drawMaSphere(matrix, light, model, metalTextureSphereTouche,
						sphereModel);
				GLES20.glDisable(GLES20.GL_BLEND);
			}

			// // Put position of all Spheres
			for (MaSphere co : buff) {
				translateAndScaleASphere(co.getX(), co.getY(), co.getZ(),
						co.getRayon());

				GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
						GLES20.GL_ONE_MINUS_SRC_ALPHA);
				GLES20.glEnable(GLES20.GL_BLEND);
				co.drawMaSphere(matrix, light, model, metalTextureSphere,
						sphereModel);
				GLES20.glDisable(GLES20.GL_BLEND);
			}

		} else {
			// // Put position of all Spheres
			if (typeSelection.equals("dichotomie")) {
				if (!enCoursList.isEmpty()) {
					if (!enCoursCibleList.isEmpty()) {
						if (backList.contains(cibleCoords)) {
							translateAndScaleASphere(cibleCoords.getX(),
									cibleCoords.getY(), cibleCoords.getZ(),
									cibleCoords.getRayon());

							cibleCoords.drawMaSphere(matrix, light, model,
									metalTextureSphereCibleBack, sphereModel);
						} else {
							translateAndScaleASphere(cibleCoords.getX(),
									cibleCoords.getY(), cibleCoords.getZ(),
									cibleCoords.getRayon());

							cibleCoords.drawMaSphere(matrix, light, model,
									metalTextureSphereCibleFront, sphereModel);
						}
					}

					// // Put position of all Spheres
					for (MaSphere co : listCoords) {
						if (backList.contains(co)) {
							translateAndScaleASphere(co.getX(), co.getY(),
									co.getZ(), co.getRayon());

							GLES20.glBlendFunc(
									GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
									GLES20.GL_ONE_MINUS_SRC_ALPHA);
							GLES20.glEnable(GLES20.GL_BLEND);
							co.drawMaSphere(matrix, light, model,
									metalTextureSphereToucheBack, sphereModel);
							GLES20.glDisable(GLES20.GL_BLEND);
						} else {
							translateAndScaleASphere(co.getX(), co.getY(),
									co.getZ(), co.getRayon());

							GLES20.glBlendFunc(
									GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
									GLES20.GL_ONE_MINUS_SRC_ALPHA);
							GLES20.glEnable(GLES20.GL_BLEND);
							co.drawMaSphere(matrix, light, model,
									metalTextureSphereTouche, sphereModel);
							GLES20.glDisable(GLES20.GL_BLEND);
						}
					}
				} else {
					MaSphere aSphere;

					if (!enCoursCibleList.isEmpty()) {
						// // Put position of all Spheres
						translateAndScaleASphere(cibleCoords.getX(),
								cibleCoords.getY(), cibleCoords.getZ(),
								cibleCoords.getRayon());

						cibleCoords.drawMaSphere(matrix, light, model,
								metalTextureSphereCible, sphereModel);
					}

					HashSet<MaSphere> buff = new HashSet<>();
					buff.addAll(listCoords);
					buff.removeAll(listCollisions);

					// // Put position of all Spheres
					for (MaSphere co : listCollisions) {
						translateAndScaleASphere(co.getX(), co.getY(),
								co.getZ(), co.getRayon());

						GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
								GLES20.GL_ONE_MINUS_SRC_ALPHA);
						GLES20.glEnable(GLES20.GL_BLEND);
						co.drawMaSphere(matrix, light, model,
								metalTextureSphereTouche, sphereModel);
						GLES20.glDisable(GLES20.GL_BLEND);
					}

					// // Put position of all Spheres
					for (MaSphere co : buff) {
						translateAndScaleASphere(co.getX(), co.getY(),
								co.getZ(), co.getRayon());

						GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
								GLES20.GL_ONE_MINUS_SRC_ALPHA);
						GLES20.glEnable(GLES20.GL_BLEND);
						co.drawMaSphere(matrix, light, model,
								metalTextureSphere, sphereModel);
						GLES20.glDisable(GLES20.GL_BLEND);
					}
				}
				// Cas d'un parcours en circulation ou avec un scrolling
			} else {
				accessListLock.lock();
				try {

					if (globalList.contains(cibleCoords)) {
						if (!backList.contains(cibleCoords)) {
							translateAndScaleASphere(cibleCoords.getX(),
									cibleCoords.getY(), cibleCoords.getZ(),
									cibleCoords.getRayon());

							cibleCoords.drawMaSphere(matrix, light, model,
									metalTextureSphereCibleFront, sphereModel);
						} else {

							translateAndScaleASphere(cibleCoords.getX(),
									cibleCoords.getY(), cibleCoords.getZ(),
									cibleCoords.getRayon());

							cibleCoords.drawMaSphere(matrix, light, model,
									metalTextureSphereCible, sphereModel);
						}
					}
					// Put position of all Spheres
					for (MaSphere co : listCoords) {
						if (!backList.contains(co)) {
							translateAndScaleASphere(co.getX(), co.getY(),
									co.getZ(), co.getRayon());

							GLES20.glBlendFunc(
									GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
									GLES20.GL_ONE_MINUS_SRC_ALPHA);
							GLES20.glEnable(GLES20.GL_BLEND);
							co.drawMaSphere(matrix, light, model,
									metalTextureSphereTouche, sphereModel);
							GLES20.glDisable(GLES20.GL_BLEND);
						} else {

							translateAndScaleASphere(co.getX(), co.getY(),
									co.getZ(), co.getRayon());

							GLES20.glBlendFunc(
									GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
									GLES20.GL_ONE_MINUS_SRC_ALPHA);
							GLES20.glEnable(GLES20.GL_BLEND);
							co.drawMaSphere(matrix, light, model,
									metalTextureSphere, sphereModel);
							GLES20.glDisable(GLES20.GL_BLEND);
						}
					}
				} finally {
					accessListLock.unlock();
				}
			}

		}

		if (cylindre.isVisible() && cylindre.isCreated()) {

			/*************************************************************************************
			 * Draw a cylinder. Translate the cylinder into the screen.
			 */
			translateAndScaleACylindre(cylindre.getX(), cylindre.getY(),
					cylindre.getZ(), cylindre.getRadius(), cylindre.getLength());

			GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
					GLES20.GL_ONE_MINUS_SRC_ALPHA);
			GLES20.glEnable(GLES20.GL_BLEND);
			cylindre.drawCylinder(matrix, light, model, textureCylindre);
			GLES20.glDisable(GLES20.GL_BLEND);

			translateAndScaleACylindre(cylindreIn.getX(), cylindreIn.getY(),
					cylindreIn.getZ(), cylindreIn.getRadius(),
					cylindreIn.getLength());

			GLES20.glBlendFunc(GLES20.GL_ONE_MINUS_CONSTANT_COLOR,
					GLES20.GL_ONE_MINUS_SRC_ALPHA);
			GLES20.glEnable(GLES20.GL_BLEND);
			cylindreIn.drawCylinder(matrix, light, model, textureCylindre);
			GLES20.glDisable(GLES20.GL_BLEND);

		}

		// Put position of the cube
		// This multiplies the view matrix by the model matrix, and stores
		// the
		// result in the MVP matrix
		// (which currently contains model * view).
		Matrix.setIdentityM(matrix.getmModelMatrix(), 0);
		Matrix.translateM(matrix.getmModelMatrix(), 0, 0.0f, 0.0f, 0.0f);

		Matrix.multiplyMV(light.getmLightPosInWorldSpace(), 0,
				light.getmLightModelMatrix(), 0,
				light.getmLightPosInModelSpace(), 0);
		Matrix.multiplyMV(light.getmLightPosInEyeSpace(), 0,
				matrix.getmViewMatrix(), 0, light.getmLightPosInWorldSpace(), 0);

		Matrix.multiplyMM(matrix.getmMVPMatrix(), 0, matrix.getmViewMatrix(),
				0, matrix.getmModelMatrix(), 0);

		// Pass in the modelview matrix.
		GLES20.glUniformMatrix4fv(model.getmMVMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);

		// This multiplies the modelview matrix by the projection matrix,
		// and
		// stores the result in the MVP matrix
		// (which now contains model * view * projection).
		Matrix.multiplyMM(matrix.getmTemporaryMatrix(), 0,
				matrix.getmProjectionMatrix(), 0, matrix.getmMVPMatrix(), 0);
		System.arraycopy(matrix.getmTemporaryMatrix(), 0,
				matrix.getmMVPMatrix(), 0, 16);

		// Pass in the combined matrix.
		GLES20.glUniformMatrix4fv(model.getmMVPMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);
	}

	public Set<MaSphere> getListCollisions() {
		return listCollisions;
	}

	private void translateAndScaleASphere(float x, float y, float z, float rayon) {
		Matrix.setIdentityM(matrix.getmModelMatrix(), 0);
		Matrix.translateM(matrix.getmModelMatrix(), 0, x, y, z);
		Matrix.scaleM(matrix.getmModelMatrix(), 0, rayon, rayon, rayon);
		// This multiplies the view matrix by the model matrix, and stores
		// the
		// result in the MVP matrix
		// (which currently contains model * view).
		Matrix.multiplyMM(matrix.getmMVPMatrix(), 0, matrix.getmViewMatrix(),
				0, matrix.getmModelMatrix(), 0);

		// Pass in the modelview matrix.
		GLES20.glUniformMatrix4fv(model.getmMVMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);

		// This multiplies the modelview matrix by the projection matrix,
		// and
		// stores the result in the MVP matrix
		// (which now contains model * view * projection).
		Matrix.multiplyMM(matrix.getmTemporaryMatrix(), 0,
				matrix.getmProjectionMatrix(), 0, matrix.getmMVPMatrix(), 0);
		System.arraycopy(matrix.getmTemporaryMatrix(), 0,
				matrix.getmMVPMatrix(), 0, 16);

		// Pass in the combined matrix.
		GLES20.glUniformMatrix4fv(model.getmMVPMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);
	}

	private void translateAndScaleACylindre(float x, float y, float z,
			float rayon, float lenght) {
		Matrix.setIdentityM(matrix.getmModelMatrix(), 0);
		Matrix.translateM(matrix.getmModelMatrix(), 0, x, y, z);
		Matrix.scaleM(matrix.getmModelMatrix(), 0, rayon, rayon, lenght);
		// This multiplies the view matrix by the model matrix, and stores
		// the
		// result in the MVP matrix
		// (which currently contains model * view).
		Matrix.multiplyMM(matrix.getmMVPMatrix(), 0, matrix.getmViewMatrix(),
				0, matrix.getmModelMatrix(), 0);

		// Pass in the modelview matrix.
		GLES20.glUniformMatrix4fv(model.getmMVMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);

		// This multiplies the modelview matrix by the projection matrix,
		// and
		// stores the result in the MVP matrix
		// (which now contains model * view * projection).
		Matrix.multiplyMM(matrix.getmTemporaryMatrix(), 0,
				matrix.getmProjectionMatrix(), 0, matrix.getmMVPMatrix(), 0);
		System.arraycopy(matrix.getmTemporaryMatrix(), 0,
				matrix.getmMVPMatrix(), 0, 16);

		// Pass in the combined matrix.
		GLES20.glUniformMatrix4fv(model.getmMVPMatrixHandle(), 1, false,
				matrix.getmMVPMatrix(), 0);
	}

	public void setCylinder(float xpos, float ypos, float radius,
			DisplayMetrics displayMetrics) {
		float x = ((xpos / displayMetrics.widthPixels) * 2f) - 1f;
		
		int heightScreen = activity.getScreen_heights()*2;
		if(ypos > (activity.getActionBarHeight() + activity.getStatusBarHeight()+(cylindre.getRadius()*2)) && ypos < (heightScreen - activity.getNavigationBarHeight())){
			float y = (((ypos - (activity.getActionBarHeight() + activity.getStatusBarHeight()))/(heightScreen - activity.getNavigationBarHeight()-(activity.getActionBarHeight() + activity.getStatusBarHeight()))) * -3f) + 1.5f + cylindre.getOriginalRadius();
			cylindre.setY(y);
			cylindreIn.setY(y);
		}
		cylindre.setX(-x);
		cylindre.setRadius(radius);
		cylindreIn.setX(-x);
		cylindreIn.setRadius(radius);
		// TODO Auto-generated method stub
	}

	public Set<MaSphere> getListCollisionsDepart() {
		return listCollisionsDepart;
	}

	public void setListCollisionsDepart(Set<MaSphere> listCollisionsDepart) {
		this.listCollisionsDepart = listCollisionsDepart;
	}

	public Cylinder getCylindre() {
		return cylindre;
	}

	public Cylinder getCylindreIn() {
		return cylindreIn;
	}

	public MaSphere getCibleCoords() {
		return cibleCoords;
	}

	public void setListCollisions(Set<MaSphere> listCollisions) {
		this.listCollisions = listCollisions;
	}

	public Set<MaSphere> getListCoords() {
		return listCoords;
	}

	public void setCibleCoords(MaSphere cibleCoords) {
		this.cibleCoords = cibleCoords;
	}

	public void setListCoords(Set<MaSphere> listCoords) {
		this.listCoords = listCoords;
	}

	public Set<MaSphere> getEnCoursCibleList() {
		return enCoursCibleList;
	}

	public void setEnCoursCibleList(Set<MaSphere> enCoursCibleList) {
		this.enCoursCibleList = enCoursCibleList;
	}

	public Set<MaSphere> getEnCoursList() {
		return enCoursList;
	}

	public void setEnCoursList(Set<MaSphere> enCoursList) {
		this.enCoursList = enCoursList;
	}

	public Stack<Set<MaSphere>> getAllPreviousList() {
		return allPreviousList;
	}

	public void setAllPreviousList(Stack<Set<MaSphere>> allPreviousList) {
		this.allPreviousList = allPreviousList;
	}

	public Stack<Set<MaSphere>> getAllPreviousCibleList() {
		return allPreviousCibleList;
	}

	public void setAllPreviousCibleList(
			Stack<Set<MaSphere>> allPreviousCibleList) {
		this.allPreviousCibleList = allPreviousCibleList;
	}

	public Set<MaSphere> getGlobalList() {
		return globalList;
	}

	public void setGlobalList(Set<MaSphere> globalList) {
		this.globalList = globalList;
	}

	public Set<MaSphere> getBackList() {
		return backList;
	}

	public void setBackList(Set<MaSphere> backList) {
		this.backList = (HashSet<MaSphere>) backList;
	}

	public Set<MaSphere> getFrontList() {
		return frontList;
	}

	public void setFrontList(Set<MaSphere> frontList) {
		this.frontList = (HashSet<MaSphere>) frontList;
	}

	public String getTypeSelection() {
		return typeSelection;
	}

	public void setTypeSelection(String typeSelection) {
		this.typeSelection = typeSelection;
	}

	public ArrayList<Integer> getListZones() {
		return listZones;
	}

	public void setListZones(ArrayList<Integer> listZones) {
		this.listZones = listZones;
	}

	public boolean isCibleIsTouch() {
		return cibleIsTouch;
	}

	public void setCibleIsTouch(boolean cibleIsTouch) {
		this.cibleIsTouch = cibleIsTouch;
	}

	public List<MaSphere> getListLogSpheres() {
		return listLogSpheres;
	}

	public void setListLogSpheres(List<MaSphere> listLogSpheres) {
		this.listLogSpheres = listLogSpheres;
	}

	public boolean isCreated() {
		return created;
	}

	public void setCreated(boolean created) {
		this.created = created;
	}

}
