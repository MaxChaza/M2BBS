package com.example.prism3;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.TimeZone;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.ConfigurationInfo;
import android.content.res.Resources;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Display;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;

import com.example.prism3.utils.XMLBuilder;

// Activity which manages 3D application 
public class PrismActivityWithTopView extends Activity implements
		android.content.DialogInterface.OnClickListener {

	// Parameters of PrismActivity
	private static Integer nbSpheres;
	private static Integer nbDivisions;
	private static Float tailleSpheres;
	private static String typeSelection;
	private static String participant;
	private static String serie;

	/** Hold a reference to our GLSurfaceView */
	private PrismGLSurfaceTopView mGLSurfaceView;

	/** Hold a reference to our PrismRenderer */
	private PrismRendererTopView mRenderer;

	// Informations of device
	private DisplayMetrics displayMetrics;

	// Logs
	private Integer nbDivisionsScrollable;
	private Integer zoneEnCours = 0;
	private Integer clickUndo = 0;
	private Integer clickFront = 0;
	private Integer clickBack = 0;
	private Integer move = 0;
	private Integer touchCount;
	private float startX, startY, stopX, stopY;
	private float starting_distance;
	private boolean resize = true;
	private boolean cibleTouchee;
	private boolean slideTouchee;
	private int nbClickRecherche = 0;

	private ArrayList<ArrayList<HashMap>> listTask = new ArrayList<ArrayList<HashMap>>();
	private ArrayList<HashMap<String, String>> listLogs = new ArrayList<HashMap<String, String>>();

	private HashMap hashBuff = new HashMap<>();

	// Buttons to select the target
	private boolean frontIsSelectable;
	private boolean backIsSelectable;
	private boolean undoIsSelectable;
	private boolean validateIsSelectable;

	// Dialog frame
	private AlertDialog.Builder builder;
	private AlertDialog dialog;

	private XMLBuilder xmlLogs;
	private int screen_width;
	private int screen_heights;
	private int actionBarHeight;
	private int navigationBarHeight;
	private int statusBarHeight;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Layout deserialisation
		setContentView(R.layout.activity_prism_with_top_view);

		slideTouchee = false;

		/**
		 * Get all objects on layout
		 */
		builder = new AlertDialog.Builder(this);
		builder.setMessage(R.string.dialog_message).setTitle(
				R.string.dialog_title);
		builder.setPositiveButton("OK", this);
		dialog = builder.create();

		mGLSurfaceView = (PrismGLSurfaceTopView) findViewById(R.id.gl_surface_view_with_top_view);

		// Parameters recovery
		nbSpheres = getIntent().getIntExtra("nbSpheres", 1);
		nbDivisions = getIntent().getIntExtra("nbDivisions", 1);
		tailleSpheres = getIntent().getFloatExtra("tailleSpheres", 0.04f);
		typeSelection = getIntent().getStringExtra("typeSelection");
		participant = getIntent().getStringExtra("participant");
		serie = getIntent().getStringExtra("serie");

		xmlLogs = new XMLBuilder(getApplicationContext(), nbSpheres,
				nbDivisions, tailleSpheres, typeSelection, participant, serie);

		// Check if the system supports OpenGL ES 2.0.
		final ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
		final ConfigurationInfo configurationInfo = activityManager
				.getDeviceConfigurationInfo();
		final boolean supportsEs2 = configurationInfo.reqGlEsVersion >= 0x20000;

		if (supportsEs2) {
			// Request an OpenGL ES 2.0 compatible context.
			mGLSurfaceView.setEGLContextClientVersion(2);

			displayMetrics = new DisplayMetrics();
			getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
			Display display = getWindowManager().getDefaultDisplay();

			TypedValue tv = new TypedValue();
			getApplicationContext().getTheme().resolveAttribute(
					android.R.attr.actionBarSize, tv, true);
			actionBarHeight = getResources().getDimensionPixelSize(
					tv.resourceId);

			Resources resources = getApplicationContext().getResources();
			navigationBarHeight = resources.getIdentifier(
					"navigation_bar_height", "dimen", "android");
			navigationBarHeight = resources
					.getDimensionPixelSize(navigationBarHeight);

			resources = getApplicationContext().getResources();
			statusBarHeight = resources.getIdentifier("status_bar_height",
					"dimen", "android");
			statusBarHeight = resources.getDimensionPixelSize(statusBarHeight);

			screen_width = display.getWidth() / 2; // to be used later for
													// navigation with touch
													// screen
			screen_heights = display.getHeight() / 2;

			// Set the renderer to our renderer, defined below.
			mRenderer = new PrismRendererTopView(this, nbSpheres, nbDivisions,
					tailleSpheres);
			mRenderer.setTypeSelection(typeSelection);

			mGLSurfaceView.setRenderer(mRenderer, displayMetrics.density);
			mGLSurfaceView.setRenderMode(mGLSurfaceView.RENDERMODE_WHEN_DIRTY);

		} else {
			// This is where you could create an OpenGL ES 1.x compatible
			// renderer if you wanted to support both ES 1 and ES 2.
			return;
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public boolean onTouchEvent(MotionEvent me) {
		// Count number of touch

		if (mRenderer.isCreated()) {
			touchCount = me.getPointerCount();
			if (mRenderer.getCylindre().isVisible()) {
				if (me.getAction() == MotionEvent.ACTION_DOWN) {

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "Task");
					hashBuff.put("target", mRenderer.getCibleCoords().getId()
							.toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					mRenderer.getCylindre().setCreated(true);

					hashBuff = new HashMap<>();
					hashBuff.put("name", "ListOfSphere");

					ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
					HashMap<String, String> hashSpheres;
					for (MaSphere sphere : mRenderer.getListLogSpheres()) {
						hashSpheres = new HashMap<String, String>();
						hashSpheres.put("name", "Sphere");
						hashSpheres.put("id", sphere.getId().toString());
						hashSpheres.put("x", sphere.getX().toString());
						hashSpheres.put("y", sphere.getY().toString());
						hashSpheres.put("z", sphere.getZ().toString());
						listSpheres.add(hashSpheres);
					}
					hashBuff.put("spheres", listSpheres);
					listLogs.add(hashBuff);

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "1");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "CylinderEvent");
					hashBuff.put("type", "1");
					hashBuff.put("x",
							((Float) mRenderer.getCylindre().getX()).toString());
					hashBuff.put("y",
							((Float) mRenderer.getCylindre().getY()).toString());
					hashBuff.put("radius", ((Float) mRenderer.getCylindre()
							.getRadius()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					// System.out.println("ACTION_DOWN");
				}

				if (me.getAction() == MotionEvent.ACTION_MOVE
						&& touchCount == 1) {
					float xpos = me.getX();
					float ypos = me.getY();

					mRenderer.setCylinder(xpos, ypos, mRenderer.getCylindre()
							.getRadius(), displayMetrics);
					mGLSurfaceView.requestRender();

					HashSet<MaSphere> listSphereAdded = new HashSet<>();
					HashSet<MaSphere> listSphereRemoved = new HashSet<>();
					boolean cibleIsTouchedBeforeMoved = mRenderer
							.isCibleIsTouch();

					if (!mRenderer.getListCollisions().isEmpty()) {
						listSphereRemoved.addAll(mRenderer.getListCollisions());
					}

					mRenderer.setListCollisions(mRenderer.getCylindre()
							.collateCylinder(
									(HashSet<MaSphere>) mRenderer
											.getListCoords()));

					if (!mRenderer.getListCollisions().isEmpty()) {
						listSphereAdded.addAll(mRenderer.getListCollisions());
						listSphereAdded.removeAll(listSphereRemoved);
						listSphereRemoved.removeAll(mRenderer
								.getListCollisions());
					}
					mRenderer.setCibleIsTouch(mRenderer.getCylindre()
							.isCollateCylinderAndCible(
									mRenderer.getCibleCoords()));

					if (cibleIsTouchedBeforeMoved
							&& !mRenderer.isCibleIsTouch())
						listSphereRemoved.add(mRenderer.getCibleCoords());

					if (!cibleIsTouchedBeforeMoved
							&& mRenderer.isCibleIsTouch())
						listSphereAdded.add(mRenderer.getCibleCoords());

					for (MaSphere s : listSphereAdded) {
						hashBuff = new HashMap<String, String>();
						hashBuff.put("name", "SphereEvent");
						hashBuff.put("type", "1");
						hashBuff.put("id", ((Integer) s.getId()).toString());
						hashBuff.put(
								"time",
								((Long) Calendar.getInstance(
										TimeZone.getTimeZone("UTC"))
										.getTimeInMillis()).toString());
						listLogs.add(hashBuff);
					}

					for (MaSphere s : listSphereRemoved) {
						hashBuff = new HashMap<String, String>();
						hashBuff.put("name", "SphereEvent");
						hashBuff.put("type", "0");
						hashBuff.put("id", ((Integer) s.getId()).toString());
						hashBuff.put(
								"time",
								((Long) Calendar.getInstance(
										TimeZone.getTimeZone("UTC"))
										.getTimeInMillis()).toString());
						listLogs.add(hashBuff);
					}

					for (MaSphere s : mRenderer.getListCollisions()) {

					}
					if (mRenderer.isCibleIsTouch()) {

						if (!slideTouchee) {
							Uri notification = RingtoneManager

							.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
							Ringtone r = RingtoneManager.getRingtone(
									getApplicationContext(), notification);
							r.play();

							cibleTouchee = true;
							slideTouchee = true;
						}
					} else {

						cibleTouchee = false;
						slideTouchee = false;
					}
					move++;

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "2");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "CylinderEvent");
					hashBuff.put("type", "2");
					hashBuff.put("x",
							((Float) mRenderer.getCylindre().getX()).toString());
					hashBuff.put("y",
							((Float) mRenderer.getCylindre().getY()).toString());
					hashBuff.put("radius", ((Float) mRenderer.getCylindre()
							.getRadius()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					// System.out.println("ACTION_MOVE && touchCount == 1 && !resize");
				}

				if (me.getAction() == MotionEvent.ACTION_UP && touchCount == 1) {
					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "CylinderEvent");
					hashBuff.put("type", "4");
					hashBuff.put("x",
							((Float) mRenderer.getCylindre().getX()).toString());
					hashBuff.put("y",
							((Float) mRenderer.getCylindre().getY()).toString());
					hashBuff.put("radius", ((Float) mRenderer.getCylindre()
							.getRadius()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "3");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					float xpos = me.getX();
					float ypos = me.getY();

					// mGLSurfaceView.requestRender();
					mRenderer.setListCollisions(mRenderer.getCylindre()
							.collateCylinder(
									(HashSet<MaSphere>) mRenderer
											.getListCoords()));
					mRenderer.setCibleIsTouch(mRenderer.getCylindre()
							.isCollateCylinderAndCible(
									mRenderer.getCibleCoords()));

					mRenderer.getGlobalList().addAll(
							mRenderer.getListCollisions());

					if (mRenderer.isCibleIsTouch()) {

						mRenderer.setListCoords(mRenderer.getListCollisions());
						mRenderer.getGlobalList().add(
								mRenderer.getCibleCoords());
						mRenderer.getGlobalList().addAll(
								mRenderer.getListCollisions());

						mRenderer.getEnCoursCibleList().add(
								mRenderer.getCibleCoords());
						mRenderer.getEnCoursList().addAll(
								mRenderer.getListCollisions());
						if (typeSelection.equals("dichotomie"))
							sortListsDichotomie();
						else
							sortListsEnProfondeur();

						mRenderer.getListCollisionsDepart().clear();
						mRenderer.getListCollisionsDepart().addAll(
								mRenderer.getGlobalList());

						nbDivisionsScrollable = mRenderer
								.getListCollisionsDepart().size() - 1;

						mRenderer.getCylindre().setVisible(false);
						mRenderer.setListCoords(mRenderer.getListCollisions());
						if (mRenderer.getGlobalList().size() > 1) {
							frontIsSelectable = true;
							backIsSelectable = true;
						}

						cibleTouchee = true;

						hashBuff = new HashMap<>();
						hashBuff.put("name", "ListOfDisplayedSphere");
						if (!mRenderer.getGlobalList().isEmpty())
							hashBuff.put("nb", ((Integer) mRenderer
									.getGlobalList().size()).toString());
						hashBuff.put(
								"time",
								((Long) Calendar.getInstance(
										TimeZone.getTimeZone("UTC"))
										.getTimeInMillis()).toString());

						ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
						HashMap<String, String> hashSpheres;
						for (MaSphere sphere : mRenderer.getGlobalList()) {
							hashSpheres = new HashMap<String, String>();
							hashSpheres.put("name", "DisplayedSphere");
							hashSpheres.put("id", sphere.getId().toString());

							listSpheres.add(hashSpheres);
						}
						hashBuff.put("spheres", listSpheres);
						listLogs.add(hashBuff);

					} else {
						validation();
					}

					if (!mRenderer.getGlobalList().isEmpty()) {
						List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
								mRenderer.getGlobalList());
						Collections.sort(listArrayBack);
						MaSphere sphereSelect = listArrayBack.get(0);
						hashBuff = new HashMap<String, String>();
						hashBuff.put("name", "SphereEvent");
						hashBuff.put("id", sphereSelect.getId().toString());
						hashBuff.put("type", "2");
						hashBuff.put(
								"time",
								((Long) Calendar.getInstance(
										TimeZone.getTimeZone("UTC"))
										.getTimeInMillis()).toString());
						listLogs.add(hashBuff);
					} else {
						// System.out.println("SANS CYLINDRE");
					}

					// System.out.println("ACTION_UP && touchCount==1");
				}

				if (me.getAction() == MotionEvent.ACTION_POINTER_2_DOWN) {
					resize = true;
					starting_distance = (float) Math.sqrt((Math.pow(
							(me.getX(0) - me.getX(1)), 2))
							+ (Math.pow((me.getY(0) - me.getY(1)), 2)));

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "4");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put("d", ((Float) starting_distance).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					// System.out.println("ACTION_POINTER_2_DOWN");
				}

				if (me.getAction() == MotionEvent.ACTION_MOVE
						&& touchCount == 2) {
					float final_distance = (float) Math.sqrt((Math.pow(
							(me.getX(0) - me.getX(1)), 2))
							+ (Math.pow((me.getY(0) - me.getY(1)), 2)));
					float scale = mRenderer.getCylindre().getRadius()
							* (final_distance / starting_distance);

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "4");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put("d", ((Float) scale).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

					if (scale > 0.05 && scale < 0.5) {
						mRenderer.getCylindre().setRadius(scale);
						mRenderer.getCylindreIn().setRadius(scale);

						hashBuff = new HashMap<String, String>();
						hashBuff.put("name", "CylinderEvent");
						hashBuff.put("type", "3");
						hashBuff.put("x", ((Float) mRenderer.getCylindre()
								.getX()).toString());
						hashBuff.put("y", ((Float) mRenderer.getCylindre()
								.getY()).toString());
						hashBuff.put("radius", ((Float) mRenderer.getCylindre()
								.getRadius()).toString());
						hashBuff.put(
								"time",
								((Long) Calendar.getInstance(
										TimeZone.getTimeZone("UTC"))
										.getTimeInMillis()).toString());
						listLogs.add(hashBuff);

					}
					mRenderer.setListCollisions(mRenderer.getCylindre()
							.collateCylinder(
									(HashSet<MaSphere>) mRenderer
											.getListCoords()));
					mRenderer.setCibleIsTouch(mRenderer.getCylindre()
							.isCollateCylinderAndCible(
									mRenderer.getCibleCoords()));

					if (mRenderer.isCibleIsTouch()) {

						if (!cibleTouchee) {
							Uri notification = RingtoneManager
									.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
							Ringtone r = RingtoneManager.getRingtone(
									getApplicationContext(), notification);
							r.play();
							cibleTouchee = true;
							validateIsSelectable = true;
						}
					} else {

						cibleTouchee = false;
					}

					// System.out.println("ACTION_POINTER_2_DOWN");
				}
				mGLSurfaceView.requestRender();

			} else {
				if (me.getAction() == MotionEvent.ACTION_DOWN) {

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "1");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);

				}

				if (me.getAction() == MotionEvent.ACTION_MOVE) {

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "2");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);
				}

				if (me.getAction() == MotionEvent.ACTION_UP) {

					hashBuff = new HashMap<String, String>();
					hashBuff.put("name", "TouchEvent");
					hashBuff.put("type", "3");
					hashBuff.put("x", ((Float) me.getX()).toString());
					hashBuff.put("y", ((Float) me.getY()).toString());
					hashBuff.put(
							"time",
							((Long) Calendar.getInstance(
									TimeZone.getTimeZone("UTC"))
									.getTimeInMillis()).toString());
					listLogs.add(hashBuff);
				}

				//
				// Technique d'interaction : Scrolling
				//
				if (typeSelection.equals("scroll")) {

					// Validation de la sphere sélectionnée
					// Zone : Bas Gauche
					if (me.getAction() == MotionEvent.ACTION_UP) {
						if (me.getX() <= screen_width
								&& me.getY() > screen_heights) {
							hashBuff = new HashMap<String, String>();
							hashBuff.put("name", "KeyEvent");
							hashBuff.put("code", "1");
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());
							listLogs.add(hashBuff);

							validation();

						}
					}

					// Scrolling pour circuler dans l'espace sur l'axe des Z
					// Zone : Droite
					if (me.getX() > screen_width) {

						Float height = (float) screen_heights * 2;

						Float ySelect = me.getY();
						Integer nbSphereRemoved = -(((int) ((nbDivisionsScrollable * ySelect) / height)) - nbDivisionsScrollable);

						if (zoneEnCours != nbSphereRemoved) {

							zoneEnCours = nbSphereRemoved;
							mRenderer.getAccessListLock().lock();
							try {

								mRenderer.getGlobalList().clear();
								mRenderer.getGlobalList().addAll(
										mRenderer.getListCollisionsDepart());

								List<MaSphere> list = new ArrayList(
										mRenderer.getGlobalList());
								Collections.sort(list);

								for (int i = 0; i < nbSphereRemoved; i++) {
									MaSphere iSphere = list.get(i);
									mRenderer.getGlobalList().remove(iSphere);
								}

								mRenderer.getListCoords().clear();
								mRenderer.getListCoords().addAll(
										mRenderer.getGlobalList());

								sortListsEnProfondeur();

								hashBuff = new HashMap<String, String>();
								hashBuff.put("name", "KeyEvent");
								hashBuff.put("code", "3");
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());
								listLogs.add(hashBuff);

								hashBuff = new HashMap<>();
								hashBuff.put("name", "ListOfDisplayedSphere");
								if (!mRenderer.getGlobalList().isEmpty())
									hashBuff.put("nb", ((Integer) mRenderer
											.getGlobalList().size()).toString());
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());

								ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
								HashMap<String, String> hashSpheres;
								for (MaSphere sphere : mRenderer
										.getGlobalList()) {
									hashSpheres = new HashMap<String, String>();
									hashSpheres.put("name", "DisplayedSphere");
									hashSpheres.put("id", sphere.getId()
											.toString());

									listSpheres.add(hashSpheres);
								}
								hashBuff.put("spheres", listSpheres);
								listLogs.add(hashBuff);

								if (!mRenderer.getGlobalList().isEmpty()) {
									List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
											mRenderer.getGlobalList());
									Collections.sort(listArrayBack);
									MaSphere sphereSelect = listArrayBack
											.get(0);
									hashBuff = new HashMap<String, String>();
									hashBuff.put("name", "SphereEvent");
									hashBuff.put("id", sphereSelect.getId()
											.toString());
									hashBuff.put("type", "2");
									hashBuff.put(
											"time",
											((Long) Calendar
													.getInstance(
															TimeZone.getTimeZone("UTC"))
													.getTimeInMillis())
													.toString());
									listLogs.add(hashBuff);
								}
								mGLSurfaceView.requestRender();
							} finally {
								mRenderer.getAccessListLock().unlock();
							}
						}
					}

				} else {
					//
					// Technique d'interaction : Dichotomie ou Circulation
					//
					if (me.getAction() == MotionEvent.ACTION_UP) {

						if (me.getX() <= screen_width
								&& me.getY() > screen_heights) {
							hashBuff = new HashMap<String, String>();
							hashBuff.put("name", "KeyEvent");
							hashBuff.put("code", "1");
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());
							listLogs.add(hashBuff);

							validation();

						}

						if (me.getX() > screen_width
								&& me.getY() > screen_heights
								&& frontIsSelectable) {
							if (typeSelection.equals("dichotomie")) {

								nbClickRecherche++;
								clickFront++;

								mRenderer.getAllPreviousCibleList().push(
										mRenderer.getEnCoursCibleList());
								mRenderer.getAllPreviousList().push(
										mRenderer.getEnCoursList());

								undoIsSelectable = true;

								HashSet<MaSphere> cibles = new HashSet<MaSphere>();
								HashSet<MaSphere> spheres = new HashSet<MaSphere>();
								for (MaSphere aSphere : mRenderer
										.getFrontList()) {
									if (mRenderer.getEnCoursCibleList()
											.contains(aSphere))
										cibles.add(aSphere);
									else
										spheres.add(aSphere);
								}

								mRenderer.setListCoords(spheres);
								mRenderer.setListCollisions(spheres);

								mRenderer.setEnCoursCibleList(cibles);
								mRenderer.setEnCoursList(spheres);

								mRenderer.getGlobalList().removeAll(
										mRenderer.getBackList());
								sortListsDichotomie();

								if (mRenderer.getGlobalList().size() == 1) {
									backIsSelectable = false;
									frontIsSelectable = false;
								}
								hashBuff = new HashMap<String, String>();
								hashBuff.put("name", "KeyEvent");
								hashBuff.put("code", "2");
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());
								listLogs.add(hashBuff);

								hashBuff = new HashMap<>();
								hashBuff.put("name", "ListOfDisplayedSphere");
								if (!mRenderer.getGlobalList().isEmpty())
									hashBuff.put("nb", ((Integer) mRenderer
											.getGlobalList().size()).toString());
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());

								ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
								HashMap<String, String> hashSpheres;
								for (MaSphere sphere : mRenderer
										.getGlobalList()) {
									hashSpheres = new HashMap<String, String>();
									hashSpheres.put("name", "DisplayedSphere");
									hashSpheres.put("id", sphere.getId()
											.toString());

									listSpheres.add(hashSpheres);
								}
								hashBuff.put("spheres", listSpheres);
								listLogs.add(hashBuff);
							}
							if (!mRenderer.getGlobalList().isEmpty()) {
								List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
										mRenderer.getGlobalList());
								Collections.sort(listArrayBack);
								MaSphere sphereSelect = listArrayBack.get(0);
								hashBuff = new HashMap<String, String>();
								hashBuff.put("name", "SphereEvent");
								hashBuff.put("id", sphereSelect.getId()
										.toString());
								hashBuff.put("type", "2");
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());
								listLogs.add(hashBuff);
							}
							// else
							// System.out.println("Front");
							mGLSurfaceView.requestRender();
						}
						if (me.getX() <= screen_width
								&& me.getY() <= screen_heights
								&& undoIsSelectable) {

							clickUndo++;
							if (nbClickRecherche == 1)
								undoIsSelectable = false;

							if (mRenderer.getGlobalList().size() == 1) {
								backIsSelectable = true;
								frontIsSelectable = true;

							}
							nbClickRecherche--;

							mRenderer.setEnCoursCibleList(mRenderer
									.getAllPreviousCibleList().pop());
							mRenderer.setEnCoursList(mRenderer
									.getAllPreviousList().pop());

							mRenderer.setListCoords(mRenderer.getEnCoursList());
							mRenderer.setListCollisions(mRenderer
									.getEnCoursList());

							mRenderer.getGlobalList().addAll(
									mRenderer.getEnCoursCibleList());
							mRenderer.getGlobalList().addAll(
									mRenderer.getEnCoursList());

							if (typeSelection.equals("dichotomie"))
								sortListsDichotomie();
							else
								sortListsEnProfondeur();

							hashBuff = new HashMap<String, String>();
							hashBuff.put("name", "KeyEvent");
							hashBuff.put("code", "0");
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());
							listLogs.add(hashBuff);

							hashBuff = new HashMap<>();
							hashBuff.put("name", "ListOfDisplayedSphere");
							if (!mRenderer.getGlobalList().isEmpty())
								hashBuff.put("nb", ((Integer) mRenderer
										.getGlobalList().size()).toString());
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());

							ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
							HashMap<String, String> hashSpheres;
							for (MaSphere sphere : mRenderer.getGlobalList()) {
								hashSpheres = new HashMap<String, String>();
								hashSpheres.put("name", "DisplayedSphere");
								hashSpheres
										.put("id", sphere.getId().toString());

								listSpheres.add(hashSpheres);
							}
							hashBuff.put("spheres", listSpheres);
							listLogs.add(hashBuff);

							if (!mRenderer.getGlobalList().isEmpty()) {
								List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
										mRenderer.getGlobalList());
								Collections.sort(listArrayBack);
								MaSphere sphereSelect = listArrayBack.get(0);
								hashBuff = new HashMap<String, String>();
								hashBuff.put("name", "SphereEvent");
								hashBuff.put("id", sphereSelect.getId()
										.toString());
								hashBuff.put("type", "2");
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());
								listLogs.add(hashBuff);
							}
							// else
							// System.out.println("Undo");
							mGLSurfaceView.requestRender();
						}
						if (me.getX() > screen_width
								&& me.getY() <= screen_heights
								&& backIsSelectable) {

							nbClickRecherche++;
							clickBack++;

							mRenderer.getAllPreviousCibleList().push(
									mRenderer.getEnCoursCibleList());
							mRenderer.getAllPreviousList().push(
									mRenderer.getEnCoursList());

							undoIsSelectable = true;

							HashSet<MaSphere> cibles = new HashSet<MaSphere>();
							HashSet<MaSphere> spheres = new HashSet<MaSphere>();
							for (MaSphere aSphere : mRenderer.getBackList()) {
								if (mRenderer.getEnCoursCibleList().contains(
										aSphere))
									cibles.add(aSphere);
								else
									spheres.add(aSphere);
							}

							mRenderer.setListCoords(spheres);
							mRenderer.setListCollisions(spheres);

							mRenderer.setEnCoursCibleList(cibles);
							mRenderer.setEnCoursList(spheres);

							if (typeSelection.equals("dichotomie")) {
								mRenderer.getGlobalList().removeAll(
										mRenderer.getFrontList());
								sortListsDichotomie();
							} else {
								List<MaSphere> list = new ArrayList(
										mRenderer.getGlobalList());
								Collections.sort(list);
								MaSphere firstSphere = list.get(0);
								mRenderer.getGlobalList().remove(firstSphere);
								sortListsEnProfondeur();
							}

							if (mRenderer.getGlobalList().size() == 1) {
								backIsSelectable = false;
								frontIsSelectable = false;

							}
							hashBuff = new HashMap<String, String>();
							hashBuff.put("name", "KeyEvent");
							hashBuff.put("code", "3");
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());
							listLogs.add(hashBuff);

							hashBuff = new HashMap<>();
							hashBuff.put("name", "ListOfDisplayedSphere");
							if (!mRenderer.getGlobalList().isEmpty())
								hashBuff.put("nb", ((Integer) mRenderer
										.getGlobalList().size()).toString());
							hashBuff.put(
									"time",
									((Long) Calendar.getInstance(
											TimeZone.getTimeZone("UTC"))
											.getTimeInMillis()).toString());

							ArrayList<HashMap<String, String>> listSpheres = new ArrayList<HashMap<String, String>>();
							HashMap<String, String> hashSpheres;
							for (MaSphere sphere : mRenderer.getGlobalList()) {
								hashSpheres = new HashMap<String, String>();
								hashSpheres.put("name", "DisplayedSphere");
								hashSpheres
										.put("id", sphere.getId().toString());

								listSpheres.add(hashSpheres);
							}
							hashBuff.put("spheres", listSpheres);
							listLogs.add(hashBuff);

							if (!mRenderer.getGlobalList().isEmpty()) {
								List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
										mRenderer.getGlobalList());
								Collections.sort(listArrayBack);
								MaSphere sphereSelect = listArrayBack.get(0);
								hashBuff = new HashMap<String, String>();
								hashBuff.put("name", "SphereEvent");
								hashBuff.put("id", sphereSelect.getId()
										.toString());
								hashBuff.put("type", "2");
								hashBuff.put(
										"time",
										((Long) Calendar.getInstance(
												TimeZone.getTimeZone("UTC"))
												.getTimeInMillis()).toString());
								listLogs.add(hashBuff);
							}
							// else
							// System.out.println("Back");
							mGLSurfaceView.requestRender();
						}
					}
				}
			}
		}
		return true;
	}

	@Override
	protected void onResume() {
		// The activity must call the GL surface view's onResume() on activity
		// onResume().
		super.onResume();
		mGLSurfaceView.onResume();
	}

	@Override
	protected void onPause() {
		// The activity must call the GL surface view's onPause() on activity
		// onPause().
		super.onPause();
		mGLSurfaceView.onPause();
	}

	@SuppressWarnings("unchecked")
	private void validation() {
		mRenderer.setCreated(false);
		if (!mRenderer.getGlobalList().isEmpty()) {
			List<MaSphere> listArrayBack = new ArrayList<MaSphere>(
					mRenderer.getGlobalList());
			Collections.sort(listArrayBack);
			MaSphere sphereSelect = listArrayBack.get(0);
			hashBuff = new HashMap<String, String>();
			hashBuff.put("name", "SphereEvent");
			hashBuff.put("id", sphereSelect.getId().toString());
			hashBuff.put("type", "3");
			hashBuff.put("time",
					((Long) Calendar.getInstance(TimeZone.getTimeZone("UTC"))
							.getTimeInMillis()).toString());
			listLogs.add(hashBuff);
		}
		ArrayList<HashMap> list = new ArrayList<HashMap>();
		list.addAll(listLogs);
		listTask.add(list);
		initLogs();

		if (mRenderer.getListZones().size() != 0) {
			mRenderer.createTest();

		} else {
			dialog.show();
			dialog.setCanceledOnTouchOutside(false);
			xmlLogs.write(listTask);
		}

		validateIsSelectable = false;
		undoIsSelectable = false;
		frontIsSelectable = false;
		backIsSelectable = false;
		cibleTouchee = false;

		slideTouchee = false;
		nbClickRecherche = 0;
	}

	private void initLogs() {
		clickUndo = 0;
		clickFront = 0;
		clickBack = 0;
		move = 0;
		touchCount = 0;
		nbClickRecherche = 0;

		listLogs.clear();

	}

	@Override
	public void onClick(DialogInterface d, int which) {
		this.finish();
	}

	public void sortListsDichotomie() {
		int i = 0;
		List<MaSphere> list = new ArrayList(mRenderer.getGlobalList());
		Collections.sort(list);

		mRenderer.setFrontList(new HashSet<MaSphere>());
		mRenderer.setBackList(new HashSet<MaSphere>());

		for (MaSphere aSphere : list) {

			if (i < list.size() / 2) {
				mRenderer.getFrontList().add(aSphere);
			} else {
				mRenderer.getBackList().add(aSphere);
			}
			i++;
		}
	}

	public void sortListsEnProfondeur() {
		int i = 0;
		List<MaSphere> list = new ArrayList(mRenderer.getGlobalList());

		List<MaSphere> listArrayBack = new ArrayList<MaSphere>(list);
		Collections.sort(listArrayBack);
		listArrayBack.remove(0);
		mRenderer.setBackList(new HashSet<MaSphere>());
		mRenderer.getBackList().addAll(listArrayBack);

		mRenderer.setFrontList(new HashSet<MaSphere>());
	}

	public PrismGLSurfaceTopView getmGLSurfaceView() {
		return mGLSurfaceView;
	}

	public void setmGLSurfaceView(PrismGLSurfaceTopView mGLSurfaceView) {
		this.mGLSurfaceView = mGLSurfaceView;
	}

	public int getScreen_heights() {
		return screen_heights;
	}

	public void setScreen_heights(int screen_heights) {
		this.screen_heights = screen_heights;
	}

	public int getActionBarHeight() {
		return actionBarHeight;
	}

	public void setActionBarHeight(int actionBarHeight) {
		this.actionBarHeight = actionBarHeight;
	}

	public int getNavigationBarHeight() {
		return navigationBarHeight;
	}

	public void setNavigationBarHeight(int navigationBarHeight) {
		this.navigationBarHeight = navigationBarHeight;
	}

	public int getStatusBarHeight() {
		return statusBarHeight;
	}

	public void setStatusBarHeight(int statusBarHeight) {
		this.statusBarHeight = statusBarHeight;
	}

}