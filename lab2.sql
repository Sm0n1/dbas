-- lösningar

-- 1
SELECT Title, string_agg(Tag, ', ' ORDER BY Tag) Tags FROM Post INNER JOIN PostTag USING (PostID) GROUP BY PostID ORDER BY Title;

-- 2
SELECT PostID, Title, ranking FROM (SELECT PostID, Title, dense_rank() OVER (ORDER BY COUNT(1) DESC) ranking FROM PostTag INNER JOIN Post USING (PostID) INNER JOIN Likes USING (PostID) WHERE Tag = '#leadership' GROUP BY PostID, Title) AS t WHERE ranking < 6;

-- 3 (we use row_number instead of ranking just incase someone subscribes twice during the same day)
SELECT generate_series AS week, (SELECT COUNT(1) FROM (SELECT UserID, date, row_number() OVER (PARTITION BY UserID ORDER BY date) ranking FROM Subscription) AS t WHERE ranking = 1 AND date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS new_customers, (SELECT COUNT(1) FROM (SELECT UserID, date, row_number() OVER (PARTITION BY UserID ORDER BY date) ranking FROM Subscription) AS t WHERE ranking > 1 AND date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS kept_customers, (SELECT COUNT(1) FROM Post WHERE date_part('year', date) = 2024 AND date_part('week', date) = generate_series) AS activity FROM generate_series(1,30);

-- 4
SELECT name, EXISTS(SELECT 1 FROM Friend WHERE Friend.UserID = t.UserID OR Friend.FriendID = t.UserID) AS has_friends, date AS registration_date FROM (SELECT UserID, name, date, row_number() OVER (PARTITION BY UserID ORDER BY date) FROM Users INNER JOIN Subscription USING (UserID)) AS t WHERE row_number = 1 AND date_part('month', date) = 1 ORDER BY name;

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
SELECT name, EVERY(many_likes) AS received_likes FROM (SELECT p.PostID, p.UserID, COUNT(1) > 49 AS many_likes FROM Post p INNER JOIN Likes l USING (PostID) WHERE date_part('month', p.date) = 3 GROUP BY p.PostID) AS viral INNER JOIN Users USING (UserID) GROUP BY UserID, name ORDER BY name;
