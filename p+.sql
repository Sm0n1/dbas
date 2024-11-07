-- __ENTITIES__
CREATE TABLE department(
    department_name TEXT PRIMARY KEY,
    building_nr     INT NOT NULL
);

CREATE TABLE patient(
    patient_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_name    TEXT NOT NULL,
    diagnoses       TEXT NOT NULL,
    age             INT NOT NULL -- this would have been much smarter: date_of_birth TIMESTAMP NOT NULL,
);

CREATE TABLE employee(
    employee_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    mentor_id       INT REFERENCES employee,
    employee_name   TEXT NOT NULL,
    phone_number    TEXT NOT NULL,

    CHECK (employee_id != mentor_id)
);

-- __WEAK_ENTITIES__
CREATE TABLE  employee_doctor(
    employee_id     INT REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    specialization  TEXT NOT NULL,
    room_nr         INT NOT NULL
);

CREATE TABLE employee_nurse(
    employee_id     INT REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    degree          TEXT NOT NULL
);

-- __RELATIONSHIPS__
CREATE TABLE works_at(
    employee_id     INT  REFERENCES employee(employee_id) ON DELETE CASCADE PRIMARY KEY,
    department_name TEXT REFERENCES department(department_name) ON DELETE CASCADE,
    starting_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE treating(
    employee_id     INT REFERENCES employee_doctor(employee_id) ON DELETE CASCADE, -- reference of reference
    patient_id      INT REFERENCES patient(patient_id) ON DELETE CASCADE,

    PRIMARY KEY (employee_id, patient_id)
);