CREATE TABLE user_account(
    user_account_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name               TEXT NOT NULL -- name, middle name, family name, title, etc
);

CREATE TABLE friendship(
    user_account_id_a       INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    user_account_id_b       INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,

    PRIMARY KEY (user_account_id_a, user_account_id_b),
    CHECK (user_account_id_a < user_account_id_b) -- No duplicates friendships nor self friendships are allowed
);

CREATE TABLE subscription(
    user_account_id         INT REFERENCES user_account(user_account_id) ON DELETE CASCADE PRIMARY KEY,
    payment_date            DATE NOT NULL,
    payment_method          TEXT NOT NULL CHECK (payment_method IN ('klarna', 'swish', 'card', 'bitcoin'))
);

CREATE TABLE tag(
    tag_id                  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_name                TEXT UNIQUE NOT NULL Check (tag_name IN ('crypto', 'studying', 'question', 'social'))
);

CREATE TABLE post(
    post_id                 INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- >= 0 because identity
    user_account_id         INT NOT NULL REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    title                   TEXT,
    place                   TEXT,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE text_post(
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    contents                TEXT NOT NULL
);

CREATE TABLE image_post(
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    image_url               TEXT NOT NULL,
    image_filter            TEXT
);

CREATE TABLE video_post(
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE PRIMARY KEY,
    video_url               TEXT NOT NULL,
    codec                   TEXT NOT NULL
);

CREATE TABLE post_like(
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE,
    user_account_id         INT REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (post_id, user_account_id)
);

CREATE TABLE post_tag(
    post_id                 INT REFERENCES post(post_id) ON DELETE CASCADE,
    tag_id                  INT REFERENCES tag(tag_id) ON DELETE CASCADE,

    PRIMARY KEY (post_id, tag_id)
);

CREATE TABLE activity(
    activity_id             INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_account_id         INT NOT NULL REFERENCES user_account(user_account_id) ON DELETE CASCADE,
    title                   TEXT NOT NULL,
    place                   TEXT NOT NULL,
    start_time              TIMESTAMP NOT NULL,
    end_time                TIMESTAMP NOT NULL,

    CHECK (start_time <= end_time)
);

CREATE TABLE activity_attendee(
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

-- __USERS__
INSERT INTO user_account(full_name) VALUES
    ('Ada Adaway'),
    ('Bob Bates'),
    ('Carl Cheseman'),
    ('Drew Duckett'),
    ('Eva Eden'),
    ('Fia Fawl');

-- __FRIENDSHIPS__
INSERT INTO friendship(user_account_id_a, user_account_id_b) VALUES (
    (SELECT user_account_id FROM user_account WHERE full_name = 'Ada Adaway'),
    (SELECT user_account_id FROM user_account WHERE full_name = 'Bob Bates')
);
INSERT INTO friendship(user_account_id_a, user_account_id_b) VALUES (
    (SELECT user_account_id FROM user_account WHERE full_name = 'Bob Bates'),
    (SELECT user_account_id FROM user_account WHERE full_name = 'Carl Cheseman')
);
INSERT INTO friendship(user_account_id_a, user_account_id_b) VALUES (
    (SELECT user_account_id FROM user_account WHERE full_name = 'Carl Cheseman'),
    (SELECT user_account_id FROM user_account WHERE full_name = 'Drew Duckett')
);
INSERT INTO friendship(user_account_id_a, user_account_id_b) VALUES (
    (SELECT user_account_id FROM user_account WHERE full_name = 'Drew Duckett'),
    (SELECT user_account_id FROM user_account WHERE full_name = 'Eva Eden')
);

-- __POSTS__
WITH new_post AS (
    INSERT INTO post(user_account_id, title) VALUES (
        6,
        'Beware the tism'
    ) RETURNING post_id
) INSERT INTO text_post(post_id, contents) VALUES (
    (SELECT post_id FROM new_post),
    E'The tism skulks in places dark.\nA honeyed smile and pupils stark.\nWhen watching it, it''s staying still,\nbut turn away,\nit goes to kill.'
);
WITH new_post AS (
    INSERT INTO post(user_account_id, title) VALUES (
        6,
        'Mike Hat'
    ) RETURNING post_id
) INSERT INTO image_post(post_id, image_url) VALUES (
    (SELECT post_id FROM new_post),
    'https://images.app.goo.gl/ctqRYtkwnSKtRSvcA'
);
WITH new_post AS (
    INSERT INTO post(user_account_id, title) VALUES (
        6,
        'What makes good rat?'
    ) RETURNING post_id
) INSERT INTO video_post(post_id, video_url, codec) VALUES (
    (SELECT post_id FROM new_post),
    'https://www.youtube.com/watch?v=Jpqo3ZcA5bA',
    'mp4'
);

-- __TAGS__
INSERT INTO tag (tag_name) VALUES ('crypto'), ('studying'), ('question'), ('social') ON CONFLICT (tag_name) DO NOTHING;
INSERT INTO post_tag(post_id, tag_id) SELECT 3, tag_id FROM tag WHERE tag_name IN ('social', 'question');

-- __LIKES__
INSERT INTO post_like(post_id, user_account_id) VALUES (1, 6), (2, 6), (3, 6);

-- __EVENTS__
INSERT INTO activity(user_account_id, title, place, start_time, end_time) VALUES (
    6,
    'Christmas Party',
    'Fia''s home',
    '2024-12-24 18:00:00'::TIMESTAMP,
    '2024-12-25 18:00:00'::TIMESTAMP
);

-- __SUBSCRIPTIONS__
INSERT INTO subscription(user_account_id, payment_date, payment_method) VALUES
    (1, CURRENT_TIMESTAMP, 'swish'),
    (2, CURRENT_TIMESTAMP, 'swish'),
    (3, CURRENT_TIMESTAMP, 'swish'),
    (4, CURRENT_TIMESTAMP, 'swish'),
    (5, CURRENT_TIMESTAMP, 'swish'),
    (6, CURRENT_TIMESTAMP, 'bitcoin');

-- __QUERIES__
-- Display user's full names
SELECT full_name FROM user_account;

-- Display friend releationships
SELECT ua_a.full_name AS user_a_name, ua_b.full_name AS user_b_name
FROM friendship f
JOIN user_account ua_a ON f.user_account_id_a = ua_a.user_account_id
JOIN user_account ua_b ON f.user_account_id_b = ua_b.user_account_id;

-- Display posts
SELECT p.post_id, p.user_account_id, p.title, p.place, p.created_at, tp.contents
FROM post p
JOIN text_post tp ON p.post_id = tp.post_id;

SELECT p.post_id, p.user_account_id, p.title, p.place, p.created_at, ip.image_url, ip.image_filter
FROM post p
JOIN image_post ip ON p.post_id = ip.post_id;

SELECT p.post_id, p.user_account_id, p.title, p.place, p.created_at, vp.video_url, vp.codec
FROM post p
JOIN video_post vp ON p.post_id = vp.post_id;

-- Display events
SELECT * FROM activity;

-- Display subscriptions
SELECT user_account_id AS subscription_id, user_account_id, payment_date, payment_method FROM subscription;