-- __ENTITIES__
CREATE TABLE department (
    department_name TEXT PRIMARY KEY,
    building_nr     INT NOT NULL
);

CREATE TABLE patient (
    patient_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_name    TEXT NOT NULL,
    diagnoses       TEXT NOT NULL,
    age             INT NOT NULL -- this would have been much smarter: date_of_birth TIMESTAMP NOT NULL,
);

CREATE TABLE employee (
    employee_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mentor_id       INT REFERENCES employee ON DELETE SET NULL,
    employee_name   TEXT NOT NULL,
    phone_number    TEXT NOT NULL,

    CHECK (employee_id != mentor_id)
);

-- __WEAK_ENTITIES__
CREATE TABLE  employee_doctor (
    employee_id     INT REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    specialization  TEXT NOT NULL,
    room_nr         INT NOT NULL
);

CREATE TABLE employee_nurse (
    employee_id     INT REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    degree          TEXT NOT NULL
);

-- __RELATIONSHIPS__
CREATE TABLE works_at (
    employee_id     INT  REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    department_name TEXT REFERENCES department(department_name) ON DELETE CASCADE,
    starting_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE treating (
    employee_id     INT REFERENCES employee_doctor(employee_id) ON DELETE CASCADE, -- reference of reference
    patient_id      INT REFERENCES patient(patient_id) ON DELETE CASCADE,

    PRIMARY KEY (employee_id, patient_id)
);

-- __ADD_DEPARTMENTS__
INSERT INTO department (department_name, building_nr) VALUES
    ('Veterinary',                 55),
    ('Virology',                   994),
    ('Osteology',                  123),
    ('High Precission Operations', 333),
    ('Dermatology',                32),
    ('Finance',                    40),
    ('IT',                         1),
    ('Human Resources',            82);

-- __ADD_EMPLOYEES__
INSERT INTO employee (employee_name, phone_number) VALUES
    ('Dave Miller',          '084404770'), -- Dr. (Vet)
    ('Mike Mirror',          '082305729'), -- Dr. (Ost)
    ('Eva Kopparberg',       '081932842'), -- Dr. (Vir)
    ('Ulrika Messerschmitt', '087462989'), -- HR
    ('Sven Olofsson',        '082221759'), -- IT
    ('Saga Gustaffson',      '082389567'), -- Nurse (Vet)
    ('Björn Stark',          '082358971'), -- Nurse (Vir)
    ('Joe Blockhead',        '086842985'); -- Nothing

-- __ADD_RELATIONSHIPS__
UPDATE employee SET mentor_id = (SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller') WHERE employee_name = 'Saga Gustaffson';
UPDATE employee SET mentor_id = (SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg') WHERE employee_name = 'Björn Stark';

-- __ADD_ROLES__
INSERT INTO employee_doctor (employee_id, specialization, room_nr) VALUES
    ((SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller' LIMIT 1), 'Treatement of The Heart', 3001),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Mike Mirror' LIMIT 1), 'Rake Wound Treatement', 3002),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg' LIMIT 1), 'Blight and Corpus Treatement', 3003);

INSERT INTO employee_nurse (employee_id, degree) VALUES
    ((SELECT employee_id FROM employee WHERE employee_name = 'Björn Stark' LIMIT 1), 'Bachelor of Virology'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Saga Gustaffson' LIMIT 1), 'Masters in Animal Care');

-- __ADD_WORKS_AT__
INSERT INTO works_at (employee_id, department_name) VALUES
    ((SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller' LIMIT 1), 'Veterinary'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Mike Mirror' LIMIT 1), 'Osteology'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg' LIMIT 1), 'Virology'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Ulrika Messerschmitt' LIMIT 1), 'Human Resources'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Sven Olofsson' LIMIT 1), 'IT'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Saga Gustaffson' LIMIT 1), 'Veterinary'),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Björn Stark' LIMIT 1), 'Virology');

-- __ADD_PATIENTS__
INSERT INTO patient (patient_name, diagnoses, age) VALUES
    ('John Pork',        'false sunder',        29),     -- Eva
    ('Skeletor',         'vitamin D-deficency', 4201),   -- Eva, Miller
    ('Patrisia Noll',    'parasites',           31),     -- Eva
    ('Brian Griffin',    'terminal dullness',   17),     -- Miller
    ('Philip Borgström', 'bad stomach',         37),     -- Unassgined
    ('Julia Strong',     '???',                 19);     -- Miller

-- __ADD_TREATING__
INSERT INTO treating (employee_id, patient_id) VALUES
    ((SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'John Pork' LIMIT 1)),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'Patrisia Noll' LIMIT 1)),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Eva Kopparberg' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'Skeletor' LIMIT 1)),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'Skeletor' LIMIT 1)),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'Brian Griffin' LIMIT 1)),
    ((SELECT employee_id FROM employee WHERE employee_name = 'Dave Miller' LIMIT 1), (SELECT patient_id FROM patient WHERE patient_name = 'Julia Strong' LIMIT 1));
