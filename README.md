# Chat Application Model Database Documentation

## Database Overview

The [Chat Application Model Database](https://github.com/sudhanshutiwari264/Chat-Application-Database/blob/64eaa77ce77bc75e30fc7305ca845421003672a3/Chat_Application_DBMS.sql) is designed to provide a robust and structured data storage solution for a chat application. It serves as the backbone for managing user accounts, friend relationships, and chat messaging features within the application. This comprehensive documentation covers the database schema, tables, relationships, sample queries with outputs, and details about the implemented triggers.

## ER-Diagram

![./chat application_er.png](https://github.com/sudhanshutiwari264/Chat-Application-Database/blob/64eaa77ce77bc75e30fc7305ca845421003672a3/chat%20application_er.png "CHAT APP ER")

## Database Schema

The database schema consists of four primary tables: `admin`, `users`, `friends`, and `messages`. Each table serves a distinct purpose in supporting various aspects of the chat application.

### 1. `admin` Table

- **Table Description**: This table is responsible for storing information about administrators of the chat application.

- **Columns**:
  - `AdminId` (Primary Key): An auto-incremented unique identifier for administrators.
  - `Fullname`: The full name of the administrator.
  - `Username`: The administrator's username.
  - `Email`: The administrator's email address.
  - `Password`: The administrator's password for account access.

### 2. `users` Table

- **Table Description**: The `users` table is central to the database, managing user accounts and their related data.

- **Columns**:
  - `ID` (Primary Key): A unique identifier for users, auto-incremented.
  - `Username`: The username of the user.
  - `Email`: The email address associated with the user.
  - `DateOfBirth`: The date of birth of the user, which can be used for age-related features.
  - `Status`: User attendance status, which can be "Active" or "Inactive".
  - `AuthenticationTime`: A timestamp that gets updated when a user sends a new message.
  - `UserKey`: A unique user key associated with the user.
  - `IP`: The user's IP address.
  - `Port`: The port used by the user for communication.

### 3. `friends` Table

- **Table Description**: This table manages friend relationships between users, facilitating friend requests and connections.

- **Columns**:
  - `reqID` (Primary Key): An auto-incremented unique identifier for friend relationships.
  - `ID`: The ID of the user initiating the friend request.
  - `ProviderID`: The ID of the user who is the recipient of the friend request.

### 4. `messages` Table

- **Table Description**: The `messages` table stores chat messages exchanged between users.

- **Columns**:
  - `ID` (Primary Key): A unique identifier for chat messages, auto-incremented.
  - `FROMUID`: The ID of the message sender.
  - `ToUID`: The ID of the message receiver.
  - `SentDt`: A timestamp recording the date and time when the message was sent.
  - `ReadStatus`: A boolean flag (0 for unread, 1 for read).
  - `ReadDt`: A timestamp recording when the message was read.
  - `MessageText`: The content of the chat message.

## Example Queries and Outputs

To illustrate the functionality of the database, we provide example SQL queries with their corresponding outputs. These queries demonstrate how data can be retrieved and manipulated within the chat application.

### Query 1: Retrieve All Users and Their Friendships

```sql
SELECT u.Username AS User, f.reqID, u2.Username AS Friend
FROM users u
LEFT JOIN friends f ON u.ID = f.ID
LEFT JOIN users u2 ON f.ProviderID = u2.ID;
```

**Output**:
| User     | reqID | Friend   |
| -------- | ----- | -------- |
| ARUN     | 1     | SUDHANSHU |
| ARUN     | 2     | TARUN    |
| SUDHANSHU | 3     | ARUN     |
| TARUN    | 4     | ARUN     |
| ARU      |       |          |
| MORIN    | 6     | DEVANSHI |
| DEVANSHI | 7     | SHEETAL  |
| SHEETAL  | 8     | MOHAN    |
| MOHAN    | 9     | RAHUL    |
| RAHUL    |       |          |

### Query 2: Retrieve Messages Sent by a Specific User with Sender and Receiver Details

```sql
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID;
```

**Output** (Sample data not shown here):

| ID  | Sender   | Receiver | SentDt               | MessageText                |
| --- | -------- | -------- | --------------------- | -------------------------- |
| 1   | ARUN     | SUDHANSHU | 2023-11-06 10:00:00 | Hello, this is a message. |
| 2   | SUDHANSHU | ARUN     | 2023-11-06 10:15:00 | Hi, this is a reply.      |

### Query 3: Retrieve Unread Messages for a Specific User

```sql
SELECT m.ID, u1.Username AS Sender, u2.Username AS Receiver, m.SentDt, m.MessageText
FROM messages m
JOIN users u1 ON m.FROMUID = u1.ID
JOIN users u2 ON m.ToUID = u2.ID
WHERE m.ToUID = 1 AND m.ReadStatus = 0;
```

**Output** (Sample data not shown here):

| ID  | Sender | Receiver | SentDt               | MessageText       |
| --- | ------ | -------- | --------------------- | ----------------- |
| 3   | TARUN  | ARUN     | 2023-11-06 10:30:00 | Unread message.   |

## Triggers

Triggers are implemented in the database to perform specific actions automatically in response to certain events. Two triggers have been added to enhance real-time information management.

### 1. `updateAuthenticationTime`

- **Trigger Description**: This trigger is executed after inserting a new message into the `messages` table. It updates the `AuthenticationTime` of the sender in the `users` table, allowing tracking of user activity.

### 2. `updateUserKey`

- **Trigger Description**: The `updateUserKey` trigger is executed before updating the `Status` of a user in the `users` table. It updates the `UserKey` based on the user's status change. If the user's status changes to "Active," their `UserKey` will be prefixed with "active_," and if the status changes to "Inactive," it will be prefixed with "inactive_."

These triggers ensure that user-related information is kept up-to-date based on user actions and status changes.

This comprehensive documentation provides a detailed insight into the Chat Application Model Database, including its schema, example queries, query outputs, and triggers. It serves as a valuable resource for understanding, implementing, and maintaining the database within the context of a chat application.
