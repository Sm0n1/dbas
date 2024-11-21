-- lösningar

-- 1
SELECT title, string_agg(tag, ', ' ORDER BY tag) tags 
FROM post JOIN posttag USING(postid)
GROUP BY postid 
ORDER BY title;

-- 2
SELECT postid, title, rank 
FROM (
    SELECT postid, dense_rank() OVER (ORDER BY count(1) DESC) rank
    FROM posttag JOIN likes USING(postid)
    WHERE tag = '#leadership'
    GROUP BY postid
) rankedpost JOIN post USING(postid)
WHERE rank <= 5
ORDER BY rank;

-- 3
WITH 
    first_subscription AS (
        SELECT 
            userid,
            min(date) AS fdate,
            date_part('week', min(date)) AS fweek
        FROM subscription
        GROUP BY userid
    ),
    new_consumer AS (
        SELECT
            fweek as week,
            count(userid) AS count
        FROM first_subscription
        WHERE fweek BETWEEN 1 AND 30
        GROUP BY fweek
    ),
    kept_consumer AS (
        SELECT
            date_part('week', date) AS week, 
            count(*) AS count
        FROM subscription s
        JOIN first_subscription fs
        ON s.userid = fs.userid AND s.date > fs.fdate
        WHERE date_part('week', s.date) BETWEEN 1 AND 30
        GROUP BY week
    ),
    activity AS (
        SELECT 
            date_part('week', date) AS week,
            count(*) AS count
        FROM post
        WHERE date_part('week', date) BETWEEN 1 AND 30
        GROUP BY week
    )
SELECT
    w.week,
    coalesce(nc.count, 0) AS new_consumers,
    coalesce(kc.count, 0) AS kept_consumers,
    coalesce(a.count, 0) AS activity
FROM generate_series(1, 30) AS w(week)
LEFT JOIN new_consumer nc USING (week)
LEFT JOIN kept_consumer kc USING (week)
LEFT JOIN activity a USING (week)
ORDER BY w.week;

-- alternative 3 (we use row_number instead of ranking just incase someone subscribes twice during the same day)
SELECT generate_series AS week, (SELECT COUNT(1) FROM (SELECT UserID, date, row_number() OVER (PARTITION BY UserID ORDER BY date) ranking FROM Subscription) AS t WHERE ranking = 1 AND date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS new_customers, (SELECT COUNT(1) FROM (SELECT UserID, date, row_number() OVER (PARTITION BY UserID ORDER BY date) ranking FROM Subscription) AS t WHERE ranking > 1 AND date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS kept_customers, (SELECT COUNT(1) FROM Post WHERE date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS activity FROM generate_series(1,30);

-- 4
SELECT
    u.name,
    EXISTS (
        SELECT 1
        FROM friend f
        WHERE (j.userid = f.userid OR j.userid = f.friendid)
    ) AS has_friend,
    j.date AS registration_date
FROM (
    SELECT userid, date
    FROM subscription
    WHERE date_part('month', date) = 1
    GROUP BY userid, date
) AS j
JOIN users u USING (userid)
ORDER BY u.name;

-- 5
WITH RECURSIVE friend_chain AS (
  SELECT u.name,
         u.UserID,
         CASE WHEN f.UserID = u.UserID THEN f.FriendID ELSE f.UserID END AS friend_id
  FROM Users u
  -- Remember to keep up to date with the code below.
  LEFT JOIN Friend f ON (f.UserID   = u.UserID AND NOT EXISTS(SELECT 1 FROM Friend b INNER JOIN Friend c ON (c.UserID <> u.UserID OR c.FriendID <> f.FriendID) AND (b.UserID <> c.UserID OR b.FriendID <> c.FriendID) AND (b.UserID = c.UserID OR b.UserID = c.FriendID OR b.FriendID = c.UserID OR b.FriendID = c.FriendID) WHERE (c.UserID = u.UserID OR c.FriendID = u.UserID) AND (b.UserID = f.FriendID OR b.FriendID = f.FriendID) AND (NOT (b.UserID = u.UserID AND b.FriendID = f.FriendID)) AND (NOT (b.UserID = f.FriendID AND b.FriendID = u.UserID))  AND (NOT (c.UserID = u.UserID AND c.FriendID = f.FriendID)) AND (NOT (c.UserID = f.FriendID AND c.FriendID = u.UserID))))
                     OR (f.FriendID = u.UserID AND NOT EXISTS(SELECT 1 FROM Friend b INNER JOIN Friend c ON (c.FriendID <> u.UserID OR c.FriendID <> f.UserID) AND (b.UserID <> c.UserID OR b.FriendID <> c.FriendID) AND (b.UserID = c.UserID OR b.UserID = c.FriendID OR b.FriendID = c.UserID OR b.FriendID = c.FriendID) WHERE (c.UserID = u.UserID OR c.FriendID = u.UserID) AND (b.UserID = f.UserID OR b.FriendID = f.UserID)  AND (NOT (b.UserID = u.UserID AND b.FriendID = f.UserID)) AND (NOT (b.UserID = f.UserID AND b.FriendID = u.UserID)) AND (NOT (c.UserID = u.UserID AND c.FriendID = f.UserID)) AND (NOT (c.UserID = f.UserID AND c.FriendID = u.UserID))))

  WHERE u.UserID = 20
  UNION
  SELECT u.name,
         u.UserID,
         CASE
           WHEN f.UserID = u.UserID THEN f.FriendID
           ELSE f.UserID
         END AS friend_id
  FROM Users u
       INNER JOIN friend_chain fc ON fc.friend_id = u.UserID
       LEFT JOIN Friend f ON (f.UserID   = u.UserID AND fc.UserID <> f.FriendID AND NOT EXISTS(SELECT 1 FROM Friend b INNER JOIN Friend c ON (c.UserID <> u.UserID OR c.FriendID <> f.FriendID) AND (b.UserID <> c.UserID OR b.FriendID <> c.FriendID) AND (b.UserID = c.UserID OR b.UserID = c.FriendID OR b.FriendID = c.UserID OR b.FriendID = c.FriendID) WHERE (c.UserID = u.UserID OR c.FriendID = u.UserID) AND (b.UserID = f.FriendID OR b.FriendID = f.FriendID) AND (NOT (b.UserID = u.UserID AND b.FriendID = f.FriendID)) AND (NOT (b.UserID = f.FriendID AND b.FriendID = u.UserID))  AND (NOT (c.UserID = u.UserID AND c.FriendID = f.FriendID)) AND (NOT (c.UserID = f.FriendID AND c.FriendID = u.UserID))))
                          OR (f.FriendID = u.UserID AND fc.UserID <> f.UserID   AND NOT EXISTS(SELECT 1 FROM Friend b INNER JOIN Friend c ON (c.FriendID <> u.UserID OR c.FriendID <> f.UserID) AND (b.UserID <> c.UserID OR b.FriendID <> c.FriendID) AND (b.UserID = c.UserID OR b.UserID = c.FriendID OR b.FriendID = c.UserID OR b.FriendID = c.FriendID) WHERE (c.UserID = u.UserID OR c.FriendID = u.UserID) AND (b.UserID = f.UserID OR b.FriendID = f.UserID)  AND (NOT (b.UserID = u.UserID AND b.FriendID = f.UserID)) AND (NOT (b.UserID = f.UserID AND b.FriendID = u.UserID)) AND (NOT (c.UserID = u.UserID AND c.FriendID = f.UserID)) AND (NOT (c.UserID = f.UserID AND c.FriendID = u.UserID))))
) SELECT name, userid as user_id, friend_id FROM friend_chain;

-- P+
SELECT
    name,
    COUNT(1) > 49 AS received_likes
FROM Post p
    INNER JOIN Likes l USING (PostID)
    INNER JOIN Users u ON (u.UserID = p.UserID)
WHERE date_part('month', p.date) = 3
GROUP BY p.UserID, u.name
ORDER BY name;
