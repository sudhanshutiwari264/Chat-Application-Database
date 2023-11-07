-- Create the database
CREATE DATABASE my_application;
USE my_application;

-- Create the admin table
CREATE TABLE admin (
    AdminId INT AUTO_INCREMENT PRIMARY KEY,
    Fullname VARCHAR(50) NOT NULL,
    Username VARCHAR(30) NOT NULL,
    Email VARCHAR(50) NOT NULL,
    Password VARCHAR(50) NOT NULL
);

-- Create the users table
CREATE TABLE users (
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
CREATE TABLE friends (
    reqID INT AUTO_INCREMENT PRIMARY KEY,
    ID INT NOT NULL,
    ProviderID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES users(ID),
    FOREIGN KEY (ProviderID) REFERENCES users(ID)
);

-- Create the messages table
CREATE TABLE messages (
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
CREATE TRIGGER updateAuthenticationTime
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
CREATE TRIGGER updateUserKey
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
    ('RAHUL', 'rahul@gmail.com', '1996-11-18', 'Active', NOW(), 'userkey9', '192.168.1.9', 8088);

-- Sample CRUD operations:

-- Create: Insert a new user
INSERT INTO users (Username, Email, DateOfBirth, Status, AuthenticationTime, UserKey, IP, Port)
VALUES ('NEWUSER', 'newuser@example.com', '1990-01-01', 'Active', NOW(), 'newuserkey', '192.168.1.10', 8089);

-- Create: Insert a new message
INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (1, 2, NOW(), 0, 'Hello, this is a new message.');

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

-- Create a new inactive user with friends
INSERT INTO users (Username, Email, DateOfBirth, Status, AuthenticationTime, UserKey, IP, Port)
VALUES ('John', 'john@gmail.com', '2001-03-12', 'Inactive', NOW(), 'userkey10', '192.168.1.10', 8090);

-- Create a friend for John
INSERT INTO friends (ID, ProviderID)
VALUES (10, 1);

-- Create a user with no friends
INSERT INTO users (Username, Email, DateOfBirth, Status, AuthenticationTime, UserKey, IP, Port)
VALUES ('Emily', 'emily@gmail.com', '2000-05-30', 'Active', NOW(), 'userkey11', '192.168.1.11', 8091);

-- Add new messages for various scenarios
INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (2, 1, NOW(), 1, 'Hi John, how are you?');

INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (1, 2, NOW(), 0, 'Hello Emily, I am good. Thanks!');

INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (1, 3, NOW(), 0, 'Hey Tarun, how is it going?');

INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (3, 1, NOW(), 1, 'Hi John, everything is fine.');

INSERT INTO messages (FROMUID, ToUID, SentDt, ReadStatus, MessageText)
VALUES (5, 2, NOW(), 0, 'Sudhanshu, did you receive my email?');

-- Mark some messages as "Read"
UPDATE messages SET ReadStatus = 1, ReadDt = NOW() WHERE ID IN (2, 3, 4);

-- Query 6: Retrieve unread messages for a specific user (Emily)
-- This query retrieves unread messages for Emily.
-- It checks the ReadStatus column in the messages table.

SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.ToUID = 1 AND m.ReadStatus = 2;