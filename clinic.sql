CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    dob DATE,
    gender ENUM('M','F')
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    specialty VARCHAR(50),
    phone VARCHAR(15)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

INSERT INTO Patients (name, phone, dob, gender) VALUES
('Ahmed', '0551111111', '1990-05-15', 'M'),
('Sara', '0552222222', '1985-08-20', 'F'),
('Khalid', '0553333333', '1992-11-10', 'M'),
('Mona', '0554444444', '1988-03-25', 'F'),
('Omar', '0555555555', '1995-07-30', 'M');

INSERT INTO Doctors (name, specialty, phone) VALUES
('Dr. Fahad', 'Cardiology', '0501111111'),
('Dr. Noura', 'Dermatology', '0502222222'),
('Dr. Saad', 'Orthopedics', '0503333333'),
('Dr. Laila', 'Pediatrics', '0504444444'),
('Dr. Mohammed', 'ENT', '0505555555');

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2026-07-20', 'Booked'),
(2, 2, '2026-07-21', 'Confirmed'),
(3, 3, '2026-07-22', 'Booked'),
(4, 4, '2026-07-23', 'Confirmed'),
(5, 5, '2026-07-24', 'Cancelled');

SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Appointments;
