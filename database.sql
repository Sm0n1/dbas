CREATE TABLE User(
    user_id         INT PRIMARY KEY,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
);

CREATE TABLE Friendship(
    user_id_a       INT,
    user_id_b       INT,

    PRIMARY KEY (user_id_a, user_id_b),

    FOREIGN KEY (user_id_a) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_b) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE Post(
    post_id         INT PRIMARY KEY,
    user_id         INT,
    title           VARCHAR(100),
    place           VARCHAR(100),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

CREATE TABLE TextPost(
    post_id         INT PRIMARY KEY,
    contents        TEXT,

    FOREIGN KEY (post_id) REFERENCES Post(post_id) ON DELETE CASCADE
);

CREATE TABLE ImagePost(
    post_id         INT PRIMARY KEY,
    image_url       VARCHAR(255),
    image_filter    VARCHAR(100),

    FOREIGN KEY (post_id) REFERENCES Post(post_id) ON DELETE CASCADE
);

CREATE TABLE VideoPost(
    post_id         INT PRIMARY KEY,
    video_url       VARCHAR(255),
    codec           VARCHAR(100),

    FOREIGN KEY (post_id) REFERENCES Post(post_id) ON DELETE CASCADE
);

CREATE TABLE Like(
    post_id         INT,
    user_id         INT,
    created_at      TIMESTAMP,

    PRIMARY KEY (post_id, user_id),

    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES Post(post_id) ON DELETE CASCADE
);

CREATE TABLE Tag(
    tag_id          INT PRIMARY KEY,
    tag_name        VARCHAR(100) UNIQUE
);

CREATE TABLE PostTag(
    post_id         INT,
    tag_id          INT,

    PRIMARY KEY (post_id, tag_id),

    FOREIGN KEY (post_id) REFERENCES Post(post_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES Tag(tag_id) ON DELETE CASCADE
);