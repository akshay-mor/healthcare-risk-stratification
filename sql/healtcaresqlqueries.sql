create database healthcare;
use healthcare;

create table Diagnoses (
DiagnosisID int primary key,
DiagnosisName varchar(255)
);

create table Outcomes(
OutcomeID int primary key,
OutcomeName varchar(255)
);

create table Patients(
PatientID int primary key,
Name varchar(255),
Age int,
Gender char(1),
DiagnosisID int,
AdmissionDate Date,
DischargeDate Date,
OutcomeID int,
TreatmentCost decimal(10,2),
foreign key (DiagnosisID) references Diagnoses(DiagnosisID),
foreign key (OutcomeID) references Outcomes(OutcomeID)
);

create table Labs(
LabID int primary key,
PatientID int,
TestName varchar(255),
Result decimal(10,2),
NormalRange varchar(255),
foreign key (PatientID) references Patients(PatientID)
);

-- Retrieving Detailed Patient Lab History
select p.patientID, p.name, d.diagnosisname, o.outcomename, l.testname, l.result, l.normalrange 
from patients p
join diagnoses d on p.diagnosisid = d.diagnosisid
join outcomes o on p.outcomeid = o.outcomeid
join labs l on p.patientid = l.patientid
order by p.patientid, l.testname;

-- Average lab results by Diagnosis
select d.diagnosisname, l.testname, avg(l.result) as AvgResult
from patients p
join diagnoses d on p.diagnosisid = d.diagnosisid
join labs l on p.patientid = l.patientid
group by d.diagnosisname, l.testname;

-- Abnormal Lab Results
select p.patientid, p.name, count(*) as AbnormalCount
from patients p
join labs l on p.patientid = l.patientid
where (l.testname = 'Blood Sugar' and l.result > 120) or
(l.testname = 'Cholesterol' and l.result > 200) or
(l.testname = 'Hemoglobin' and l.result < 13)
group by p.patientid, p.name
order by AbnormalCount desc;

-- Diagnosis with highest treatment cost
select d.diagnosisname, sum(p.treatmentcost) as TotalCost
from patients p
join diagnoses d on p.diagnosisid = d.diagnosisid
group by d.diagnosisname
order by TotalCost desc;

-- Patients at Risk by age and gender
select p.patientid, p.name, p.age, d.diagnosisname, o.outcomename
from patients p
join diagnoses d on p.diagnosisid = d.diagnosisid
join outcomes o on p.outcomeid = o.outcomeid
where p.age > 65 and gender = 'M' and o.outcomename != 'Recovered'
order by p.age desc;

-- Lab trends over time for a specific patients
select l.testname, l.result, p.admissiondate
from labs l
join patients p on l.patientid = p.patientid
where p.patientid in (2, 4, 6, 8, 10, 12)
order by p.admissiondate;

-- Distribution of Outcomes by Diagnosis
select d.diagnosisname, o.outcomename, count(*) as OutcomeCount
from patients p
join diagnoses d on p.diagnosisid = d.diagnosisid
join outcomes o on p.outcomeid = o.outcomeid
group by d.diagnosisname, o.outcomename
order by d.diagnosisname, o.outcomename desc;