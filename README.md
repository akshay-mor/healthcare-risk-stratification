# Healthcare Risk Stratification App

A healthcare analytics and machine-learning project that combines
relational data analysis in MySQL with a Logistic Regression model and
an interactive Streamlit application. The project explores patient
demographics, diagnoses, treatment costs, length of hospital stay,
laboratory results, and patient outcomes.

> **Project status:** Portfolio prototype. The current Streamlit
> interface runs and displays predictions. The saved model evaluation
> reveals a class-imbalance/performance issue that should be addressed
> before treating the predictions as reliable.

## Project objectives

-   Organize healthcare records in a relational MySQL database.
-   Use SQL joins and aggregations to explore diagnoses, outcomes,
    laboratory results, and treatment costs.
-   Prepare patient-level features using Python and Pandas.
-   Train a Logistic Regression classifier to distinguish recovered
    patients from patients with complicated or deceased outcomes.
-   Provide an interactive prediction interface using Streamlit.

## Technology stack

-   **Database:** MySQL
-   **Programming:** Python
-   **Data processing:** Pandas, NumPy
-   **Machine learning:** Scikit-learn (Logistic Regression)
-   **Model persistence:** Joblib
-   **Application:** Streamlit
-   **Evaluation and visualization:** classification report, confusion
    matrix, ROC curve, Matplotlib

## Dataset overview

The uploaded project data contains the following files:

  ------------------------------------------------------------------------
  File                                       Records Description
  --------------------- ---------------------------- ---------------------
  `patients.csv`                                 200 Patient ID, name,
                                                     age, gender,
                                                     diagnosis,
                                                     admission/discharge
                                                     dates, outcome and
                                                     treatment cost

  `diagnoses.csv`                                 10 Diagnosis IDs and
                                                     diagnosis names

  `outcomes.csv`                                   3 Outcome IDs and
                                                     outcome labels

  `labs.csv`                                     200 Patient laboratory
                                                     test names, results
                                                     and recorded normal
                                                     ranges

  `heart-disease.csv`                            303 Separate
                                                     heart-disease dataset
                                                     with 13 input columns
                                                     and a target column
  ------------------------------------------------------------------------

**Important:** The supplied training notebook reads `patients.csv`,
`diagnoses.csv`, `outcomes.csv` and `labs.csv`. It does not use
`heart-disease.csv` in the shown model-training workflow.

## Database design and SQL analysis

The SQL script `healtcaresqlqueries.sql` creates a database named
`healthcare` and defines four related tables:

-   `Diagnoses`
-   `Outcomes`
-   `Patients`
-   `Labs`

Primary keys are defined for the entity tables, and foreign keys connect
patients to diagnoses and outcomes, and laboratory records to patients.

The SQL queries demonstrate:

1.  Retrieving detailed patient laboratory history using multiple
    `INNER JOIN` operations.
2.  Calculating average laboratory results by diagnosis and test name.
3.  Counting selected abnormal laboratory results by patient.
4.  Summarizing total treatment cost by diagnosis.
5.  Filtering patients by age, gender and outcome.
6.  Retrieving selected patients' laboratory results alongside admission
    dates.
7.  Summarizing outcome counts by diagnosis.

## Python data preparation and feature engineering

The notebook performs the following steps:

1.  Loads patient, diagnosis, outcome and laboratory CSV files with
    Pandas.
2.  Merges patient data with diagnosis and outcome lookup tables.
3.  Converts admission and discharge dates to datetime values.
4.  Calculates `LengthOfStay` as the difference between discharge and
    admission dates.
5.  Encodes outcomes as a binary target:
    -   `Recovered` = 0
    -   `Complicated` = 1
    -   `Deceased` = 1
6.  Creates a `HighRisk` indicator using age greater than 65 or an
    outcome of `Complicated`/`Deceased`.
7.  Calculates an `AbnormalLabsCount` feature using selected laboratory
    thresholds.

The current Logistic Regression model uses only these three features:

-   `Age`
-   `LengthOfStay`
-   `TreatmentCost`

The encoded outcome (`OutcomeEmcoded` in the notebook) is the model
target. The separately calculated `HighRisk` and `AbnormalLabsCount`
columns are not currently included in the model's feature set.

## Model training and evaluation

The notebook uses:

-   `train_test_split` with a 30% test set and `random_state=42`
-   `LogisticRegression(max_iter=500)`
-   `classification_report`
-   `confusion_matrix`
-   `roc_curve` and `auc`

The saved classification report in the supplied notebook shows 72%
accuracy. However, it also shows 0 recall for class 0 and 100% recall
for class 1. The model did not predict any class 0 cases in that
evaluation. The target distribution in the supplied patient data is 137
adverse-outcome records and 63 recovered records.

Consequently, accuracy alone is misleading here. The model needs further
evaluation and improvement before its predictions should be relied upon.
Consider stratified validation, class-aware metrics, an appropriate
baseline, threshold analysis, and alternative model or class-weight
experiments.

**Interpretation limitation:** The current target is an outcome-derived
label, not the separately engineered age-based `HighRisk` label. Also,
length of stay and treatment cost may only be known after treatment has
progressed. This feature set should not be presented as an
admission-time clinical risk model.

## Streamlit application

The supplied app script (`Risk_Model.py`) provides three numeric inputs:

-   Age
-   Length of Stay (days)
-   Treatment Cost

When the user selects **Predict**, the app passes those values to the
saved model and displays:

-   A binary prediction currently labelled `High Risk` or `Low Risk`
-   The predicted probability for class 1

**Label clarification:** Because the notebook trains on the encoded
outcome (`Recovered` versus `Complicated`/`Deceased`), the current app
label `High Risk` is not an exact description of the trained target.
Until the target is changed and the model retrained, describe the output
as an adverse-outcome prediction rather than a validated clinical risk
score.

## Repository structure

A suggested GitHub repository layout is:

``` text
healthcare-risk-stratification/
│
├── data/
│   ├── patients.csv
│   ├── diagnoses.csv
│   ├── outcomes.csv
│   ├── labs.csv
│   └── heart-disease.csv
│
├── notebooks/
│   └── Risk_Modal.ipynb
│
├── sql/
│   └── healtcaresqlqueries.sql
│
├── app/
│   └── Risk_Model.py
│
├── models/
│   └── risk_model.pkl
│
├── README.md
└── requirements.txt
```

This is a recommended organization; adjust the paths to match the files
actually committed to your repository. Avoid committing real
patient-identifiable or confidential health information. Use
appropriately licensed, synthetic, or de-identified data.

## Setup and run

### 1. Clone the repository

``` bash
git clone <your-repository-url>
cd healthcare-risk-stratification
```

### 2. Create and activate a virtual environment

Windows PowerShell:

``` powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 3. Install dependencies

Create a `requirements.txt` containing the packages used by the project,
then run:

``` bash
pip install -r requirements.txt
```

Core packages include:

``` text
pandas
numpy
scikit-learn
streamlit
matplotlib
joblib
jupyter
```

### 4. Prepare the trained model artifact

The notebook currently calls `joblib.dump(model, 'Risk_Modal.ipynb')`,
while the Streamlit script loads that same filename. This conflicts with
using `.ipynb` as the notebook's file extension.

Use a separate model artifact filename, such as `models/risk_model.pkl`,
when saving the trained model, and update the app to load that same
`.pkl` file. Keep the notebook saved separately as an `.ipynb` file.
Ensure the model artifact exists before starting the app.

### 5. Run the Streamlit app

After updating the model artifact path in the app:

``` bash
streamlit run app/Risk_Model.py
```

Run the command from the repository root, or adjust the path to the app
file to match your repository layout.

## Key skills demonstrated

-   Relational database design and SQL querying
-   Multi-table joins and data aggregation
-   Data cleaning, merging and feature engineering with Pandas
-   Date-time processing and calculation of hospital length of stay
-   Binary outcome encoding
-   Logistic Regression model training
-   Classification and ROC-based evaluation
-   Model serialization with Joblib
-   Building an interactive Streamlit application

## Current limitations and recommended next steps

1.  **Improve model evaluation:** The saved report shows the model fails
    to identify class 0. Investigate class imbalance, use stratified
    validation, compare with a majority-class baseline, and report
    precision, recall, F1-score and ROC-AUC.
2.  **Align the target and app wording:** Decide whether the objective
    is adverse-outcome prediction or the separately defined `HighRisk`
    classification. Train and evaluate against the chosen target.
3.  **Review feature timing:** For admission-time prediction, use only
    information available at admission. Do not use post-admission length
    of stay or final treatment cost as if they were known at admission.
4.  **Review laboratory feature engineering:** The notebook's
    abnormal-lab logic uses `Cholestrol` (misspelled) while the CSV uses
    `Cholesterol`, so cholesterol records are not counted by that
    function. Check all test names and thresholds against the data
    dictionary and clinical context.
5.  **Separate model and notebook files:** Save the trained estimator as
    a `.pkl` file and keep the notebook as `.ipynb`.
6.  **Add reproducibility and deployment details:** Include a complete
    `requirements.txt`, consistent relative paths, and a deployment link
    if the app is hosted.

## Disclaimer

This project is an educational portfolio prototype and is not a medical
device or a clinical decision-support system. Its predictions must not
be used for diagnosis, treatment, triage, or real patient-care
decisions.
