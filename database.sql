CREATE TABLE user_account (
    user_account_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name               TEXT NOT NULL -- name, middle name, family name, title, etc
);

CREATE TABLE friendship (
    user_account_id_a       INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    user_account_id_b       INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,

    PRIMARY KEY (user_account_id_a, user_account_id_b),
    CHECK (user_account_id_a > user_account_id_b) -- No duplicates friendships nor self friendships are allowed
);

CREATE TABLE subscription (
    user_account_id         INT NOT NULL REFERENCES user_account(user_account_id) ON DELETE CASCADE PRIMARY KEY,
    payment_date            DATE NOT NULL,
    payment_method          TEXT NOT NULL CHECK (payment_method IN ('klarna', 'swish', 'card', 'bitcoin'))
);

CREATE TABLE tag (
    tag_id                  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_name                TEXT UNIQUE NOT NULL Check (tag_name IN ('crypto', 'studying', 'question', 'social'))
);

CREATE TABLE post (
    post_id                 INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- >= 0 because identity
    user_account_id         INT NOT NULL REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    title                   TEXT,
    place                   TEXT,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE text_post (
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    contents                TEXT NOT NULL
);

CREATE TABLE image_post (
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    image_url               TEXT NOT NULL,
    image_filter            TEXT
);

CREATE TABLE video_post (
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    video_url               TEXT NOT NULL,
    codec                   TEXT NOT NULL
);

CREATE TABLE post_like (
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE,
    user_account_id         INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (post_id, user_account_id)
);

CREATE TABLE post_tag (
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE,
    tag_id                  INT REFERENCES tag(tag_id) ON DELETE CASCADE,

    PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE activity (
    activity_id             INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id         INT NOT NULL REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    title                   TEXT NOT NULL,
    place                   TEXT NOT NULL,
    start_day               DATE NOT NULL,
    end_day                 DATE NOT NULL,

    CHECK (start_day <= end_day)
);

CREATE TABLE activity_attendee (
    activity_id             INT REFERENCES activity(activity_id) ON DELETE CASCADE,
    user_account_id         INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,

    PRIMARY KEY (activity_id, user_account_id)
);

-- __CONSTRAINTS__
-- Attribute based constraints performs checks on separate columns, i.e. column1 CHECK(column1 > 0).
-- Tuple based constraints performs checks on collections of columns, i.e. CHECK(column1 > 0 OR column2 > 0).

-- __TRIGGERS__
-- What is a trigger?
-- Name 3 events that can cause a trigger to activate.
-- What can be done with triggers?