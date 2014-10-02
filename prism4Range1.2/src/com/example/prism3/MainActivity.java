package com.example.prism3;

import android.R.bool;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.app.ActionBarActivity;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends ActionBarActivity {

	// Give all objects contains by the corresponding layout
	private static View rootView;

	// Declaration of interactive objects
	private static Button buttonValider;

	private static SeekBar barNbSphere;
	private static SeekBar barNbDivision;
	private static SeekBar barTailleSpheres;
	private static EditText editTextParticipant;
	private static EditText editTextSerie;

	private static RadioGroup radioSelection;
	private static RadioButton radioDichotomie;
	private static RadioButton radioCirculation;
	private static RadioButton radioScroll;

	private static CheckBox checkTopView;

	// Parameters of PrismActivity
	private static int nbSpheres = 1;
	private static int nbDivisions = 1;
	private static Float tailleSpheres = 0.2f;
	private static String typeSelection = "dichotomie";
	private static boolean topViewIsChecked = false;
	private static final int MIN = 1;
	private static final int MAX_TAILLE = 20;
	private static final int MIN_TAILLE = 4;
	private static final int MAX_RANGE = 4;
	private static final int MAX_SPHERES = 500;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		if (savedInstanceState == null) {
			getSupportFragmentManager().beginTransaction()
					.add(R.id.container, new PlaceholderFragment()).commit();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {

		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * A placeholder fragment containing a simple view.
	 */
	public static class PlaceholderFragment extends Fragment implements
			OnSeekBarChangeListener, OnClickListener, OnCheckedChangeListener {

		// View where appear progress SeekBar
		TextView textProgressSpheres;
		TextView textProgressDivisions;
		TextView textProgressTaille;

		public PlaceholderFragment() {
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {

			// Layout deserialisation
			rootView = inflater.inflate(R.layout.fragment_main, container,
					false);
			/**
			 * Get all objects on layout
			 */
			barNbDivision = (SeekBar) rootView
					.findViewById(R.id.seekBarNbDivisions);

			textProgressDivisions = (TextView) rootView
					.findViewById(R.id.textViewNbDivisions);

			barNbDivision.setMax(MAX_RANGE);
			barNbDivision.setOnSeekBarChangeListener(this);
			barNbDivision.setProgress(MIN);

			// Selection number of spheres by division
			barNbSphere = (SeekBar) rootView
					.findViewById(R.id.seekBarNbSpheres);

			textProgressSpheres = (TextView) rootView
					.findViewById(R.id.textViewNbSpheres);

			barNbSphere.setMax(MAX_SPHERES);
			barNbSphere.setOnSeekBarChangeListener(this);
			barNbSphere.setProgress(MIN);

			// Selection size of spheres
			barTailleSpheres = (SeekBar) rootView
					.findViewById(R.id.seekBarTailleSpheres);

			textProgressTaille = (TextView) rootView
					.findViewById(R.id.textViewTailleSpheres);

			barTailleSpheres.setMax(MAX_TAILLE);
			barTailleSpheres.setOnSeekBarChangeListener(this);
			barTailleSpheres.setProgress(MIN_TAILLE);

			// Choose kind of selection
			radioDichotomie = (RadioButton) rootView
					.findViewById(R.id.radioDichotomie);
			radioCirculation = (RadioButton) rootView
					.findViewById(R.id.radioCirculation);
			radioScroll = (RadioButton) rootView.findViewById(R.id.radioScroll);

			radioSelection = (RadioGroup) rootView
					.findViewById(R.id.radioSelection);
			radioSelection.setOnCheckedChangeListener(this);

			checkTopView = (CheckBox) rootView
					.findViewById(R.id.choiceTopViewCheckBox);
			checkTopView.setOnClickListener(this);
			;

			// Enter the participant's name
			editTextParticipant = (EditText) rootView
					.findViewById(R.id.champParticipant);
			editTextParticipant.setText("Chaz");

			// Enter the serie
			editTextSerie = (EditText) rootView.findViewById(R.id.champSerie);
			editTextSerie.setText("Noire");

			// Validate
			buttonValider = (Button) rootView.findViewById(R.id.buttonValider);
			buttonValider.setOnClickListener(this);

			return rootView;
		}

		@Override
		public void onProgressChanged(SeekBar seekBar, int progress,
				boolean fromUser) {
			// TODO Auto-generated method stub

			// change progress text label with current seekbar value
			// make text label for progress value
			if (seekBar.equals(barNbDivision)) {

				if (progress < MIN) {
					/*
					 * if seek bar value is lesser than min value then set min
					 * value to seek bar
					 */
					seekBar.setProgress(MIN);
				}
				textProgressDivisions.setText(seekBar.getProgress()
						+ " divisions.");
				nbDivisions = seekBar.getProgress();
				int maxByDiv = (int) (MAX_SPHERES / java.lang.Math.pow(
						nbDivisions, 3));
				barNbSphere.setMax(maxByDiv);
			}
			if (seekBar.equals(barNbSphere)) {

				if (progress < MIN) {
					/*
					 * if seek bar value is lesser than min value then set min
					 * value to seek bar
					 */
					seekBar.setProgress(MIN);
				}
				textProgressSpheres
						.setText(seekBar.getProgress() + " sphères.");
				nbSpheres = seekBar.getProgress();
			}

			if (seekBar.equals(barTailleSpheres)) {

				if (progress < MIN_TAILLE) {
					/*
					 * if seek bar value is lesser than min value then set min
					 * value to seek bar
					 */
					seekBar.setProgress(MIN_TAILLE);
				}
				tailleSpheres = (float) ((float) seekBar.getProgress() / 100.0f);
				textProgressTaille.setText(tailleSpheres.toString());
			}
		}

		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onClick(View v) {
			if (v.equals(checkTopView)) {
				if (checkTopView.isChecked())
					topViewIsChecked = true;
				else
					topViewIsChecked = false;
			}
			if (v.equals(buttonValider)) {
				if (editTextParticipant.getText().toString().equals("")
						|| editTextSerie.getText().toString().equals("")) {
					Toast.makeText(getActivity().getApplicationContext(),
							"Veuillez remplir tous les champs de saisie",
							Toast.LENGTH_LONG).show();
				} else {

					if (topViewIsChecked) {
						// Create PrismActivityWithTopView with parameters

						Intent foo = new Intent(getActivity(),
								PrismActivityWithTopView.class);
						foo.putExtra("nbSpheres", nbSpheres);
						foo.putExtra("nbDivisions", nbDivisions);
						foo.putExtra("tailleSpheres", tailleSpheres);
						foo.putExtra("typeSelection", typeSelection);
						foo.putExtra("participant", editTextParticipant
								.getText().toString());
						foo.putExtra("serie", editTextSerie.getText()
								.toString());
						startActivity(foo);
					} else {
						// Create PrismActivity with parameters
						Intent foo = new Intent(getActivity(),
								PrismActivity.class);
						foo.putExtra("nbSpheres", nbSpheres);
						foo.putExtra("nbDivisions", nbDivisions);
						foo.putExtra("tailleSpheres", tailleSpheres);
						foo.putExtra("typeSelection", typeSelection);
						foo.putExtra("participant", editTextParticipant
								.getText().toString());
						foo.putExtra("serie", editTextSerie.getText()
								.toString());
						startActivity(foo);
					}
				}
			}
		}

		@Override
		public void onCheckedChanged(RadioGroup group, int checkedId) {
			// TODO Auto-generated method stub
			RadioButton rEnCours = (RadioButton) rootView
					.findViewById(checkedId);
			if (rEnCours.equals(radioDichotomie)) {
				typeSelection = "dichotomie";
			}

			if (rEnCours.equals(radioCirculation)) {
				typeSelection = "circulation";
			}

			if (rEnCours.equals(radioScroll)) {
				typeSelection = "scroll";
			}
		}
	}
}
