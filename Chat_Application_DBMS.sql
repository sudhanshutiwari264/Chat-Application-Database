-- Create the database
CREATE DATABASE IF NOT EXISTS my_application;
USE my_application ;

-- Create the admin table
CREATE TABLE IF NOT EXISTS admin (
    AdminId INT AUTO_INCREMENT PRIMARY KEY,
    Fullname VARCHAR(50) NOT NULL,
    Username VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Password VARCHAR(50) NOT NULL
);

-- Create the users table
CREATE TABLE IF NOT EXISTS users (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Status ENUM('Active', 'Inactive') NOT NULL,
    AuthenticationTime DATETIME,
    UserKey VARCHAR(100),
    IP VARCHAR(15),
    Port INT
);

-- Create the friends table
CREATE TABLE IF NOT EXISTS friends (
    reqID INT AUTO_INCREMENT PRIMARY KEY,
    ID INT NOT NULL,
    ProviderID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES users(ID),
    FOREIGN KEY (ProviderID) REFERENCES users(ID)
);

-- Create the messages table
CREATE TABLE IF NOT EXISTS messages (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    FROMUID INT NOT NULL,
    ToUID INT NOT NULL,
    SentDt DATETIME NOT NULL,
    ReadStatus BOOLEAN,
    ReadDt DATETIME,
    MessageText TEXT
);

-- Create a trigger to update AuthenticationTime when a new message is sent
DELIMITER //
CREATE TRIGGER IF NOT EXISTS updateAuthenticationTime
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    UPDATE users
    SET AuthenticationTime = NOW()
    WHERE ID = NEW.FROMUID;
END;
//
DELIMITER ;

-- Create a trigger to update UserKey based on user Status
DELIMITER //
CREATE TRIGGER IF NOT EXISTS updateUserKey
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Active' THEN
        SET NEW.UserKey = CONCAT('active_', NEW.ID);
    ELSE
        SET NEW.UserKey = CONCAT('inactive_', NEW.ID);
    END IF;
END;
//
DELIMITER ;

-- Create a stored procedure for sending messages
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS SendMessage(IN from_user INT, IN to_user INT, IN message_text TEXT)
BEGIN
    INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
    VALUES (from_user, to_user, NOW(), 0, message_text);
END;
//
DELIMITER ;

-- Insert dummy data for admin
INSERT INTO admin (Fullname, Username, Email, Password)
VALUES
    ('Admin1', 'admin1', 'admin1@example.com', 'adminpassword');

-- Insert dummy data for users
INSERT INTO users (Username, Email, DateOfBirth, Status, AuthenticationTime, UserKey, IP, Port)
VALUES
    ('ARUN', 'arun@gmail.com', '2001-01-01', 'Active', NOW(), 'userkey1', '192.168.1.1', 8080),
    ('SUDHANSHU', 'sudhanshu@gmail.com', '2002-02-15', 'Active', NOW(), 'userkey2', '192.168.1.2', 8081),
    ('TARUN', 'tarun@gmail.com', '2003-05-20', 'Active', NOW(), 'userkey3', '192.168.1.3', 8082),
    ('ARU', 'aru@gmail.com', '1998-12-10', 'Inactive', NOW(), 'userkey4', '192.168.1.4', 8083),
    ('MORIN', 'morin@gmail.com', '1999-08-25', 'Active', NOW(), 'userkey5', '192.168.1.5', 8084),
    ('DEVANSHI', 'devanshi@gmail.com', '2002-04-30', 'Active', NOW(), 'userkey6', '192.168.1.6', 8085),
    ('SHEETAL', 'sheetal@gmail.com', '1997-03-05', 'Active', NOW(), 'userkey7', '192.168.1.7', 8086),
    ('MOHAN', 'mohan@gmail.com', '2002-07-12', 'Active', NOW(), 'userkey8', '192.168.1.8', 8087),
    ('RAHUL', 'rahul@gmail.com', '1996-11-18', 'Active', NOW(), 'userkey9', '192.168.1.9', 8088),
    ('Tina', 'tina@gmail.com', '2001-04-02', 'Active', NOW(), 'userkey22', '192.168.1.22', 8101),
    ('Ulysses', 'ulysses@gmail.com', '1997-09-17', 'Active', NOW(), 'userkey23', '192.168.1.23', 8102),
    ('Victor', 'victor@gmail.com', '2000-02-08', 'Inactive', NOW(), 'userkey24', '192.168.1.24', 8103),
    ('Wendy', 'wendy@gmail.com', '1994-06-13', 'Active', NOW(), 'userkey25', '192.168.1.25', 8104),
    ('Xander', 'xander@gmail.com', '1998-01-03', 'Active', NOW(), 'userkey26', '192.168.1.26', 8105),
    ('Yara', 'yara@gmail.com', '2002-06-26', 'Active', NOW(), 'userkey27', '192.168.1.27', 8106),
    ('Zane', 'zane@gmail.com', '1995-11-19', 'Active', NOW(), 'userkey28', '192.168.1.28', 8107),
    ('Amy', 'amy@gmail.com', '2001-07-24', 'Active', NOW(), 'userkey29', '192.168.1.29', 8108),
    ('Ben', 'ben@gmail.com', '1996-12-09', 'Active', NOW(), 'userkey30', '192.168.1.30', 8109);

-- CRUD Operations
-- Create: Insert a new user
INSERT INTO users (Username, Email, DateOfBirth, Status, AuthenticationTime, UserKey, IP, Port)
VALUES ('NEWUSER', 'newuser@example.com', '1990-01-01', 'Active', NOW(), 'newuserkey', '192.168.1.10', 8089);

-- Create: Insert a new message
CALL SendMessage(1, 2, 'Hello, this is a new message.');

-- Read: Retrieve all users
SELECT * FROM users;

-- Read: Retrieve messages sent by a specific user
SELECT * FROM messages WHERE FROMUID = 1;

-- Update: Update a user's status to 'Inactive'
UPDATE users SET Status = 'Inactive' WHERE ID = 3;

-- Update: Mark a message as 'Read'
UPDATE messages SET ReadStatus = 1, ReadDt = NOW() WHERE ID = 5;

-- Delete: Delete a specific user
DELETE FROM users WHERE ID = 4;

-- Delete: Delete all messages sent by a specific user
-- DELETE FROM messages WHERE FROMUID = 1;

-- Query 1: Retrieve all users and their friendships
-- This query retrieves all users and their friends, if they have any.
-- It joins the users and friends tables to display user and friend names.
SELECT u.Username AS User, f.reqID, u2.Username AS Friend
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
LEFT JOIN users u2 ON f.ProviderID = u2.ID;

-- Query 2: Retrieve messages sent by a specific user with sender and receiver details
-- This query retrieves messages along with sender and receiver details.
-- It establishes relationships using FROMUID and ToUID columns in the messages table.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID;

-- Query 3: Retrieve all messages between friends
-- This query retrieves all messages between friends, ensuring that both users are friends.
-- It uses subqueries to check friendship relationships.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.FROMUID IN (SELECT ID FROM friends WHERE ProviderID = m.ToUID)
  AND m.ToUID IN (SELECT ID FROM friends WHERE ProviderID = m.FROMUID);

-- Query 4: Retrieve messages sent by a specific user to their friends
-- This query retrieves messages sent by a specific user to their friends.
-- It checks if the recipient is a friend of the sender using a subquery.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.FROMUID = 1
  AND m.ToUID IN (SELECT ID FROM friends WHERE ProviderID = m.FROMUID);

-- Query 5: Retrieve unread messages for a specific user
-- This query retrieves unread messages for a specific user.
-- It checks the ReadStatus column in the messages table.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.ToUID = 1 AND m.ReadStatus = 0;

-- Query 6: Retrieve users with a specific status
-- This query retrieves users based on their status.
SELECT * FROM users WHERE Status = 'Active';

-- Query 7: Retrieve messages sent by users with a specific status
-- This query retrieves messages sent by users with a specific status.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE u1.Status = 'Active';

-- Query 8: Retrieve friends of a specific user
-- This query retrieves friends of a specific user.
SELECT u.Username AS User, f.reqID, u2.Username AS Friend
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
LEFT JOIN users u2 ON f.ProviderID = u2.ID
WHERE u.ID = 1;

-- Query 9: Retrieve messages sent to a specific user after a certain date
-- This query retrieves messages sent to a specific user after a certain date.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.ToUID = 1 AND m.SentDt > '2023-01-01';

-- Query 10: Retrieve the total number of messages sent by each user
-- This query retrieves the total number of messages sent by each user.
SELECT u.Username, COUNT(m.ID) AS TotalMessages
FROM users u
LEFT JOIN messages m ON u.ID = m.FROMUID
GROUP BY u.ID;

-- Subquery 1: Retrieve the latest message sent to each user
-- This subquery retrieves the latest message sent to each user.
-- It is used in conjunction with the main query.
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.ID = (
    SELECT MAX(ID)
    FROM messages
    WHERE ToUID = u2.ID
);

-- Subquery 2: Retrieve users who have sent more than 5 messages
-- This subquery retrieves users who have sent more than 5 messages.
-- It is used in conjunction with the main query.
SELECT u.Username
FROM users u
WHERE (
    SELECT COUNT(ID)
    FROM messages
    WHERE FROMUID = u.ID
) > 5;

-- Subquery 3: Retrieve users who have friends with a specific status
-- This subquery retrieves users who have friends with a specific status.
-- It is used in conjunction with the main query.
SELECT u.Username
FROM users u
WHERE (
    SELECT COUNT(f.reqID)
    FROM friends f
    JOIN users u2 ON f.ProviderID = u2.ID
    WHERE f.ID = u.ID AND u2.Status = 'Active'
) > 0;

-- Query 11: Retrieve the average number of messages sent by users
-- This query calculates the average number of messages sent by users.
SELECT AVG(MessageCount) AS AverageMessages
FROM (
    SELECT COUNT(m.ID) AS MessageCount
    FROM users u
    LEFT JOIN messages m ON u.ID = m.FROMUID
    GROUP BY u.ID
) AS UserMessageCounts;

-- Query 12: Retrieve users who have not sent any messages
-- This query retrieves users who have not sent any messages.
SELECT u.Username
FROM users u
LEFT JOIN messages m ON u.ID = m.FROMUID
WHERE m.ID IS NULL;

-- Query 13: Retrieve users who have friends but haven't sent messages
-- This query retrieves users who have friends but haven't sent any messages.
SELECT DISTINCT u.Username
FROM users u
JOIN friends f ON u.ID = f.ID
LEFT JOIN messages m ON u.ID = m.FROMUID
WHERE m.ID IS NULL;

-- Query 14: Retrieve users who have the maximum number of friends
-- This query retrieves users who have the maximum number of friends.
SELECT u.Username, COUNT(f.reqID) AS FriendCount
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
GROUP BY u.ID
HAVING FriendCount = (
    SELECT MAX(FriendCount)
    FROM (
        SELECT COUNT(f2.reqID) AS FriendCount
        FROM users u2
        LEFT JOIN friends f2 ON u2.ID = f2.ID
        GROUP BY u2.ID
    ) AS MaxFriendCounts
);

-- Query 15: Retrieve users who have sent messages to all their friends
-- This query retrieves users who have sent messages to all their friends.
SELECT DISTINCT u.Username
FROM users u
JOIN friends f ON u.ID = f.ID
WHERE NOT EXISTS (
    SELECT fi.reqID
    FROM friends fi
    WHERE fi.ID = u.ID
    AND fi.ProviderID NOT IN (
        SELECT ToUID
        FROM messages m
        WHERE m.FROMUID = u.ID
    )
);

-- Subquery 4: Retrieve users who have friends with more than 10 messages
-- This subquery retrieves users who have friends with more than 10 messages.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
WHERE (
    SELECT COUNT(m.ID)
    FROM messages m
    WHERE m.FROMUID = f.ProviderID
) > 10;

-- Subquery 5: Retrieve users who have the same IP address
-- This subquery retrieves users who have the same IP address.
-- It is used in conjunction with the main query.
SELECT DISTINCT u1.Username, u2.Username
FROM users u1
JOIN users u2 ON u1.IP = u2.IP
WHERE u1.ID < u2.ID;

-- Query 16: Retrieve the total number of unread messages
-- This query retrieves the total number of unread messages in the system.
SELECT COUNT(ID) AS TotalUnreadMessages
FROM messages
WHERE ReadStatus = 0;

-- Query 17: Retrieve the user who sent the most messages
-- This query retrieves the user who sent the most messages.
SELECT u.Username, COUNT(m.ID) AS MessageCount
FROM users u
LEFT JOIN messages m ON u.ID = m.FROMUID
GROUP BY u.ID
ORDER BY MessageCount DESC
LIMIT 1;

-- Query 18: Retrieve the user who has the most friends
-- This query retrieves the user who has the most friends.
SELECT u.Username, COUNT(f.reqID) AS FriendCount
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
GROUP BY u.ID
ORDER BY FriendCount DESC
LIMIT 1;

-- Query 19: Retrieve users who were active in the last 7 days
-- This query retrieves users who were active in the last 7 days based on AuthenticationTime.
SELECT *
FROM users
WHERE AuthenticationTime >= NOW() - INTERVAL 7 DAY;

-- Query 20: Retrieve messages sent on weekends
-- This query retrieves messages sent on weekends.
SELECT *
FROM messages
WHERE DAYOFWEEK(SentDt) IN (1, 7);

-- Subquery 6: Retrieve users who sent messages on weekdays
-- This subquery retrieves users who sent messages on weekdays.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN messages m ON u.ID = m.FROMUID
WHERE DAYOFWEEK(m.SentDt) BETWEEN 2 AND 6;

-- Subquery 7: Retrieve users who have not been active for more than 30 days
-- This subquery retrieves users who have not been active for more than 30 days.
-- It is used in conjunction with the main query.
SELECT ID
FROM users
WHERE AuthenticationTime < NOW() - INTERVAL 30 DAY;

-- Subquery 8: Retrieve users who have friends with the same birthdate
-- This subquery retrieves users who have friends with the same birthdate.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
WHERE EXISTS (
    SELECT fi.ID
    FROM friends fi
    JOIN users u2 ON fi.ProviderID = u2.ID
    WHERE fi.ID = u.ID
    AND DAYOFMONTH(u.DateOfBirth) = DAYOFMONTH(u2.DateOfBirth)
    AND MONTH(u.DateOfBirth) = MONTH(u2.DateOfBirth)
);
-- Query 21: Retrieve users who have sent messages to themselves
-- This query retrieves users who have sent messages to themselves.
SELECT DISTINCT u.Username
FROM users u
JOIN messages m ON u.ID = m.FROMUID
WHERE m.ToUID = u.ID;

-- Query 22: Retrieve the total number of messages sent by each user
-- This query retrieves the total number of messages sent by each user.
SELECT u.Username, COUNT(m.ID) AS MessageCount
FROM users u
LEFT JOIN messages m ON u.ID = m.FROMUID
GROUP BY u.ID;

-- Query 23: Retrieve the user who has the oldest unread message
-- This query retrieves the user who has the oldest unread message.
SELECT u.Username, m.SentDt
FROM users u
JOIN messages m ON u.ID = m.ToUID
WHERE m.ReadStatus = 0
ORDER BY m.SentDt ASC
LIMIT 1;

-- Query 24: Retrieve users who have sent messages with more than 100 characters
-- This query retrieves users who have sent messages with more than 100 characters.
SELECT DISTINCT u.Username
FROM users u
JOIN messages m ON u.ID = m.FROMUID
WHERE LENGTH(m.MessageText) > 100;

-- Query 25: Retrieve the user who has the most unread messages
-- This query retrieves the user who has the most unread messages.
SELECT u.Username, COUNT(m.ID) AS UnreadMessageCount
FROM users u
JOIN messages m ON u.ID = m.ToUID
WHERE m.ReadStatus = 0
GROUP BY u.ID
ORDER BY UnreadMessageCount DESC
LIMIT 1;

-- Subquery 9: Retrieve users who have friends with unread messages
-- This subquery retrieves users who have friends with unread messages.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN messages m ON f.ProviderID = m.ToUID
WHERE m.ReadStatus = 0;

-- Subquery 10: Retrieve users who have sent messages with the same content
-- This subquery retrieves users who have sent messages with the same content.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN messages m ON u.ID = m.FROMUID
WHERE EXISTS (
    SELECT fi.ID
    FROM friends fi
    JOIN messages mi ON fi.ProviderID = mi.ToUID
    WHERE fi.ID = u.ID
    AND mi.MessageText = m.MessageText
);


-- Trigger 1: Update UserKey on user status change
DELIMITER //
CREATE TRIGGER updateUserKeyOnStatusChange
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Active' THEN
        SET NEW.UserKey = CONCAT('active_', NEW.ID);
    ELSE
        SET NEW.UserKey = CONCAT('inactive_', NEW.ID);
    END IF;
END;
//
DELIMITER ;

-- Trigger 2: Update AuthenticationTime when a new friend is added
DELIMITER //
CREATE TRIGGER updateAuthTimeOnFriendAdd
AFTER INSERT ON friends
FOR EACH ROW
BEGIN
    UPDATE users
    SET AuthenticationTime = NOW()
    WHERE ID = NEW.ID OR ID = NEW.ProviderID;
END;
//
DELIMITER ;

-- ... (Add more triggers as needed)

-- Stored Procedure 1: Send a message
DELIMITER //
CREATE PROCEDURE sendMessage(
    IN fromUserID INT,
    IN toUserID INT,
    IN messageText TEXT
)
BEGIN
    INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
    VALUES (fromUserID, toUserID, NOW(), 0, messageText);
END;
//
DELIMITER ;

-- Stored Procedure 2: Delete user and associated messages
DELIMITER //
CREATE PROCEDURE deleteUserAndMessages(
    IN userID INT
)
BEGIN
    DELETE FROM users WHERE ID = userID;
    DELETE FROM messages WHERE FROMUID = userID OR ToUID = userID;
END;
//
DELIMITER ;

-- Query 26: Retrieve users who have friends born in the same month
-- This query retrieves users who have friends born in the same month.
SELECT DISTINCT u.Username
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE MONTH(u.DateOfBirth) = MONTH(uf.DateOfBirth);

-- Query 27: Retrieve the user with the most friends
-- This query retrieves the user with the most friends.
SELECT u.Username, COUNT(f.reqID) AS FriendCount
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
GROUP BY u.ID
ORDER BY FriendCount DESC
LIMIT 1;

-- Query 28: Retrieve messages with the longest content
-- This query retrieves messages with the longest content.
SELECT ID, MessageText
FROM messages
ORDER BY LENGTH(MessageText) DESC
LIMIT 1;

-- Query 29: Retrieve users who have sent messages to their inactive friends
-- This query retrieves users who have sent messages to their inactive friends.
SELECT DISTINCT u.Username
FROM users u
JOIN messages m ON u.ID = m.FROMUID
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE uf.Status = 'Inactive';

-- Query 30: Retrieve the average number of messages sent by active users
-- This query retrieves the average number of messages sent by active users.
SELECT AVG(MessageCount) AS AvgMessagesSent
FROM (
    SELECT u.ID, COUNT(m.ID) AS MessageCount
    FROM users u
    LEFT JOIN messages m ON u.ID = m.FROMUID
    WHERE u.Status = 'Active'
    GROUP BY u.ID
) AS ActiveUsersMessages;

-- Subquery 11: Retrieve users who have friends with more than 2 unread messages
-- This subquery retrieves users who have friends with more than 2 unread messages.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN messages m ON f.ProviderID = m.ToUID
WHERE m.ReadStatus = 0
GROUP BY u.ID
HAVING COUNT(m.ID) > 2;

-- Subquery 12: Retrieve users who have sent messages with the same IP address
-- This subquery retrieves users who have sent messages with the same IP address.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN messages m ON u.ID = m.FROMUID
WHERE EXISTS (
    SELECT fi.ID
    FROM friends fi
    JOIN messages mi ON fi.ProviderID = mi.ToUID
    WHERE fi.ID = u.ID
    AND fi.IP = u.IP
);

-- Trigger 3: Update user status to 'Inactive' if they have no friends
DELIMITER //
CREATE TRIGGER updateUserStatusOnNoFriends
AFTER DELETE ON friends
FOR EACH ROW
BEGIN
    DECLARE friendCount INT;
    SELECT COUNT(*) INTO friendCount
    FROM friends
    WHERE ID = OLD.ID OR ProviderID = OLD.ID;

    IF friendCount = 0 THEN
        UPDATE users
        SET Status = 'Inactive'
        WHERE ID = OLD.ID;
    END IF;
END;
//
DELIMITER ;

-- Trigger 4: Update user status to 'Active' if they have new unread messages
DELIMITER //
CREATE TRIGGER updateUserStatusOnUnreadMessages
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    UPDATE users
    SET Status = 'Active'
    WHERE ID = NEW.ToUID AND Status = 'Inactive';
END;
//
DELIMITER ;

-- Stored Procedure 3: Mark all messages as read for a specific user
DELIMITER //
CREATE PROCEDURE markAllMessagesAsRead(
    IN userID INT
)
BEGIN
    UPDATE messages
    SET ReadStatus = 1, ReadDt = NOW()
    WHERE ToUID = userID;
END;
//
DELIMITER ;

-- Stored Procedure 4: Retrieve a list of friends for a user
DELIMITER //
CREATE PROCEDURE getFriendList(
    IN userID INT
)
BEGIN
    SELECT u.Username
    FROM friends f
    JOIN users u ON f.ProviderID = u.ID
    WHERE f.ID = userID;
END;
//
DELIMITER ;

-- Query 31: Retrieve users who have friends with the same birth year
-- This query retrieves users who have friends with the same birth year.
SELECT DISTINCT u.Username
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE YEAR(u.DateOfBirth) = YEAR(uf.DateOfBirth);

-- Query 32: Retrieve the user with the fewest friends
-- This query retrieves the user with the fewest friends.
SELECT u.Username, COUNT(f.reqID) AS FriendCount
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
GROUP BY u.ID
ORDER BY FriendCount ASC
LIMIT 1;

-- Query 33: Retrieve messages sent on weekends
-- This query retrieves messages sent on weekends.
SELECT ID, SentDt, MessageText
FROM messages
WHERE DAYOFWEEK(SentDt) IN (1, 7);

-- Query 34: Retrieve users who have friends with the same IP address
-- This query retrieves users who have friends with the same IP address.
SELECT DISTINCT u.Username
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE u.IP = uf.IP;

-- Query 35: Retrieve messages with the highest number of words
-- This query retrieves messages with the highest number of words.
SELECT ID, MessageText, LENGTH(MessageText) - LENGTH(REPLACE(MessageText, ' ', '')) + 1 AS WordCount
FROM messages
ORDER BY WordCount DESC
LIMIT 1;

-- Subquery 13: Retrieve users who have friends born in the same month and year
-- This subquery retrieves users who have friends born in the same month and year.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE MONTH(u.DateOfBirth) = MONTH(uf.DateOfBirth) AND YEAR(u.DateOfBirth) = YEAR(uf.DateOfBirth);

-- Subquery 14: Retrieve users who have more than 2 inactive friends
-- This subquery retrieves users who have more than 2 inactive friends.
-- It is used in conjunction with the main query.
SELECT DISTINCT u.ID
FROM users u
JOIN friends f ON u.ID = f.ID
JOIN users uf ON f.ProviderID = uf.ID
WHERE uf.Status = 'Inactive'
GROUP BY u.ID
HAVING COUNT(f.reqID) > 2;

-- Trigger 5: Delete messages older than 6 months
DELIMITER //
CREATE TRIGGER deleteOldMessages
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    DELETE FROM messages
    WHERE SentDt < NOW() - INTERVAL 6 MONTH;
END;
//
DELIMITER ;

-- Trigger 6: Update user status to 'Active' if they receive a message
DELIMITER //
CREATE TRIGGER updateUserStatusOnReceivedMessage
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    UPDATE users
    SET Status = 'Active'
    WHERE ID = NEW.ToUID AND Status = 'Inactive';
END;
//
DELIMITER ;

-- Stored Procedure 5: Retrieve the latest message for a specific user
DELIMITER //
CREATE PROCEDURE getLatestMessage(
    IN userID INT
)
BEGIN
    SELECT *
    FROM messages
    WHERE ToUID = userID
    ORDER BY SentDt DESC
    LIMIT 1;
END;
//
DELIMITER ;
