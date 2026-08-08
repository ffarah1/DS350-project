DROP DATABASE IF EXISTS ClinicDB;
CREATE DATABASE ClinicDB;
USE ClinicDB;

-- 1. Patient
CREATE TABLE Patient (
    Patient_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Full_name    VARCHAR(100) NOT NULL,
    Gender       ENUM('M','F') NOT NULL,
    Phone        VARCHAR(20) UNIQUE NOT NULL,
    Age          INT NOT NULL CHECK (Age > 0)
);

-- 2. Doctor
CREATE TABLE Doctor (
    Doctor_ID    INT AUTO_INCREMENT PRIMARY KEY,
    Full_name    VARCHAR(100) NOT NULL,
    Phone        VARCHAR(20) UNIQUE NOT NULL,
    Gender       ENUM('M','F') NOT NULL,
    Specialty    VARCHAR(100) NOT NULL
);

-- 3. Appointment
CREATE TABLE Appointment (
    Appointment_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID       INT NOT NULL,
    Doctor_ID        INT NOT NULL,
    Appt_Date        DATE NOT NULL,
    Appt_Time        TIME NOT NULL,
    Status           ENUM('Scheduled','Completed','Cancelled')
                     NOT NULL DEFAULT 'Scheduled',

    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Treatment
CREATE TABLE Treatment (
    Treatment_ID     INT AUTO_INCREMENT PRIMARY KEY,
    Treatment_name   VARCHAR(100) NOT NULL,
    Description      VARCHAR(255),
    Cost             DECIMAL(10,2) NOT NULL CHECK (Cost >= 0)
);

-- 5. Appointment_Treatment
CREATE TABLE Appointment_Treatment (
    Appointment_ID   INT NOT NULL,
    Treatment_ID     INT NOT NULL,

    PRIMARY KEY (Appointment_ID, Treatment_ID),

    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (Treatment_ID) REFERENCES Treatment(Treatment_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. Medicine
CREATE TABLE Medicine (
    Medicine_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Medicine_name    VARCHAR(100) NOT NULL UNIQUE,
    Price            DECIMAL(8,2) NOT NULL CHECK (Price >= 0),
    Dosage           VARCHAR(50)
);

-- 7. Prescribes
CREATE TABLE Prescribes (
    Doctor_ID        INT NOT NULL,
    Medicine_ID      INT NOT NULL,
    Prescribed_Date  DATE NOT NULL,

    PRIMARY KEY (Doctor_ID, Medicine_ID, Prescribed_Date),

    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (Medicine_ID) REFERENCES Medicine(Medicine_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. Payment
CREATE TABLE Payment (
    Payment_ID       INT AUTO_INCREMENT PRIMARY KEY,
    Appointment_ID   INT UNIQUE NOT NULL,
    Payment_Date     DATE NOT NULL,
    Amount           DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    Payment_Type     ENUM('Cash','Card') NOT NULL,

    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Cash_Payment
CREATE TABLE Cash_Payment (
    Payment_ID   INT PRIMARY KEY,

    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 10. Card_Payment
CREATE TABLE Card_Payment (
    Payment_ID   INT PRIMARY KEY,

    FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- =========================
-- INSERT PATIENTS
-- =========================

INSERT INTO Patient (Full_name, Gender, Phone, Age) VALUES
('Ahmed Al-Ghamdi', 'M', '0501111111', 35),
('Sara Al-Otaibi', 'F', '0502222222', 28),
('Yousef Al-Qahtani', 'M', '0503333333', 24),
('Lama Al-Harbi', 'F', '0504444444', 30),
('Faisal Al-Zahrani', 'M', '0505555555', 45),
('Nora Al-Sulami', 'F', '0506666666', 22);

SELECT * FROM Patient;


-- =========================
-- INSERT DOCTORS
-- =========================

INSERT INTO Doctor (Full_name, Phone, Gender, Specialty) VALUES
('Dr. Khalid Al-Dosari', '0511111111', 'M', 'Cardiology'),
('Dr. Mona Al-Shehri', '0512222222', 'F', 'Dermatology'),
('Dr. Omar Al-Amri', '0513333333', 'M', 'Pediatrics');

SELECT * FROM Doctor;


-- =========================
-- INSERT APPOINTMENTS
-- =========================

INSERT INTO Appointment
(Patient_ID, Doctor_ID, Appt_Date, Appt_Time, Status)
VALUES
(1, 1, '2026-01-05', '09:00:00', 'Completed'),
(2, 2, '2026-01-06', '10:30:00', 'Completed'),
(3, 3, '2026-01-07', '11:00:00', 'Completed'),
(4, 1, '2026-01-08', '13:00:00', 'Scheduled'),
(5, 2, '2026-01-09', '14:15:00', 'Cancelled'),
(6, 3, '2026-01-10', '15:00:00', 'Scheduled');

SELECT * FROM Appointment;


-- =========================
-- INSERT TREATMENTS
-- =========================

INSERT INTO Treatment
(Treatment_name, Description, Cost)
VALUES
('ECG', 'Electrocardiogram and consultation', 350.00),
('Skin Allergy Treatment', 'Allergy diagnosis and medication plan', 200.00),
('Vaccination', 'Routine child vaccination', 150.00),
('Blood Pressure Check', 'Follow-up blood pressure monitoring', 100.00),
('General Checkup', 'Standard physical examination', 120.00);

SELECT * FROM Treatment;


-- =========================
-- APPOINTMENT TREATMENTS
-- =========================

INSERT INTO Appointment_Treatment
(Appointment_ID, Treatment_ID)
VALUES
(1, 1),
(1, 4),
(2, 2),
(3, 3),
(4, 4),
(6, 5);

SELECT * FROM Appointment_Treatment;


-- =========================
-- INSERT MEDICINES
-- =========================

INSERT INTO Medicine
(Medicine_name, Price, Dosage)
VALUES
('Paracetamol', 10.00, '500mg twice daily'),
('Amoxicillin', 25.00, '250mg three times daily'),
('Loratadine', 15.00, '10mg once daily'),
('Ibuprofen', 12.00, '400mg as needed'),
('Vitamin D3', 30.00, '1000IU once daily');

SELECT * FROM Medicine;


-- =========================
-- PRESCRIBES
-- =========================

INSERT INTO Prescribes
(Doctor_ID, Medicine_ID, Prescribed_Date)
VALUES
(1, 1, '2026-01-05'),
(2, 3, '2026-01-06'),
(3, 2, '2026-01-07'),
(1, 4, '2026-01-08'),
(3, 5, '2026-01-10');

SELECT * FROM Prescribes;


-- =========================
-- TRIGGER
-- مهم: قبل INSERT INTO Payment
-- =========================

DELIMITER //

CREATE TRIGGER trg_PaymentSpecialization
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    IF NEW.Payment_Type = 'Cash' THEN
        INSERT INTO Cash_Payment (Payment_ID)
        VALUES (NEW.Payment_ID);

    ELSEIF NEW.Payment_Type = 'Card' THEN
        INSERT INTO Card_Payment (Payment_ID)
        VALUES (NEW.Payment_ID);
    END IF;
END //

DELIMITER ;


-- =========================
-- INSERT PAYMENTS
-- =========================

INSERT INTO Payment
(Appointment_ID, Payment_Date, Amount, Payment_Type)
VALUES
(1, '2026-01-05', 470.00, 'Card'),
(2, '2026-01-06', 200.00, 'Cash'),
(3, '2026-01-07', 150.00, 'Cash'),
(4, '2026-01-08', 100.00, 'Card'),
(6, '2026-01-10', 120.00, 'Cash');

SELECT * FROM Payment;

SELECT * FROM Cash_Payment;

SELECT * FROM Card_Payment;


-- =========================
-- SORT PATIENTS
-- =========================

SELECT Patient_ID, Full_name, Gender, Phone, Age
FROM Patient
ORDER BY Full_name;


-- =========================
-- APPOINTMENT DETAILS
-- =========================

SELECT
    a.Appointment_ID,
    p.Full_name AS PatientName,
    d.Full_name AS DoctorName,
    d.Specialty,
    a.Appt_Date,
    a.Appt_Time,
    a.Status
FROM Appointment a
JOIN Patient p
    ON a.Patient_ID = p.Patient_ID
JOIN Doctor d
    ON a.Doctor_ID = d.Doctor_ID;


-- =========================
-- PATIENTS OF CARDIOLOGY DOCTORS
-- =========================

SELECT Full_name
FROM Patient
WHERE Patient_ID IN (
    SELECT Patient_ID
    FROM Appointment
    WHERE Doctor_ID IN (
        SELECT Doctor_ID
        FROM Doctor
        WHERE Specialty = 'Cardiology'
    )
);


-- =========================
-- PAYMENT SUMMARY
-- =========================

SELECT
    Payment_Type,
    COUNT(*) AS NumberOfPayments,
    SUM(Amount) AS TotalCollected
FROM Payment
GROUP BY Payment_Type;


-- =========================
-- UPDATE
-- =========================

UPDATE Appointment
SET Status = 'Completed'
WHERE Appointment_ID = 4;


-- =========================
-- DELETE CANCELLED APPOINTMENT
-- =========================

DELETE FROM Appointment
WHERE Status = 'Cancelled';


-- =========================
-- VIEW
-- =========================

CREATE VIEW Appointment_Summary AS
SELECT
    a.Appointment_ID,
    p.Full_name AS PatientName,
    d.Full_name AS DoctorName,
    a.Appt_Date,
    a.Status,
    COALESCE(SUM(t.Cost), 0) AS TotalTreatmentCost,
    pay.Amount AS AmountPaid,
    pay.Payment_Type
FROM Appointment a
JOIN Patient p
    ON a.Patient_ID = p.Patient_ID
JOIN Doctor d
    ON a.Doctor_ID = d.Doctor_ID
LEFT JOIN Appointment_Treatment at2
    ON at2.Appointment_ID = a.Appointment_ID
LEFT JOIN Treatment t
    ON t.Treatment_ID = at2.Treatment_ID
LEFT JOIN Payment pay
    ON pay.Appointment_ID = a.Appointment_ID
GROUP BY
    a.Appointment_ID,
    p.Full_name,
    d.Full_name,
    a.Appt_Date,
    a.Status,
    pay.Amount,
    pay.Payment_Type;

SELECT * FROM Appointment_Summary;