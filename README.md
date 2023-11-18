# Chat Application Model Database Documentation

## Database Overview

The [Chat Application Model Database](https://github.com/sudhanshutiwari264/Chat-Application-Database/blob/64eaa77ce77bc75e30fc7305ca845421003672a3/Chat_Application_DBMS.sql) is designed to provide a robust and structured data storage solution for a chat application. It serves as the backbone for managing user accounts, friend relationships, and chat messaging features within the application. This comprehensive documentation covers the database schema, tables, relationships, sample queries with outputs, and details about the implemented triggers.

## ER-Diagram

![./chat application_er.png](https://github.com/sudhanshutiwari264/Chat-Application-Database/blob/64eaa77ce77bc75e30fc7305ca845421003672a3/chat%20application_er.png "CHAT APP ER")

## Database Schema

The database schema consists of four primary tables: `admin`, `users`, `friends`, and `messages`. Each table serves a distinct purpose in supporting various aspects of the chat application.

### Users Table

- **Columns:**
  - `ID` (INT, Primary Key): Unique identifier for each user.
  - `Username` (VARCHAR): User's username.
  - `Email` (VARCHAR): User's email address.
  - `Status` (VARCHAR): User's status, can be 'Active' or 'Inactive'.
  - `AuthenticationTime` (DATETIME): Timestamp of the user's last authentication.

### Friends Table

- **Columns:**
  - `ID` (INT, Foreign Key): User ID.
  - `FriendID` (INT, Foreign Key): Friend's ID.

### Messages Table

- **Columns:**
  - `ID` (INT, Primary Key): Unique identifier for each message.
  - `FROMUID` (INT, Foreign Key): Sender's ID.
  - `ToUID` (INT, Foreign Key): Receiver's ID.
  - `MessageText` (TEXT): The content of the message.
  - `SentDt` (DATETIME): Timestamp when the message was sent.
  - `ReadStatus` (VARCHAR): Message read status, can be 'Read' or 'Unread'.

## Triggers

1. **`updateAuthenticationTime` Trigger:**
   - **Function:** Updates the `AuthenticationTime` of the sender when a new message is sent.

2. **`updateUserKey` Trigger:**
   - **Function:** Updates the `UserKey` based on the user's `Status` before each update.

3. **`updateUserKeyOnStatusChange` Trigger:**
   - **Function:** Updates `UserKey` when there is a change in the user's `Status`.

4. **`updateAuthTimeOnFriendAdd` Trigger:**
   - **Function:** Updates `AuthenticationTime` for users involved in a new friendship.

5. **`updateUserStatusOnNoFriends` Trigger:**
   - **Function:** Updates user status to 'Inactive' if they have no friends.

6. **`updateUserStatusOnUnreadMessages` Trigger:**
   - **Function:** Updates user status to 'Active' if they receive a new unread message.

7. **`deleteOldMessages` Trigger:**
   - **Function:** Deletes messages older than 6 months after a new message is inserted.

## Stored Procedures

1. **`SendMessage` Stored Procedure:**
   - **Function:** Inserts a new message into the `messages` table.

   ```sql
   CALL SendMessage(1, 2, 'Hello, Sheetal!');
   ```

2. **`markAllMessagesAsRead` Stored Procedure:**
   - **Function:** Marks all messages as read for a specific user.

   ```sql
   CALL markAllMessagesAsRead(1);
   ```

3. **`deleteUserAndMessages` Stored Procedure:**
   - **Function:** Deletes a user and their associated messages.

   ```sql
   CALL deleteUserAndMessages(2);
   ```

4. **`getFriendList` Stored Procedure:**
   - **Function:** Retrieves a list of friends for a user.

   ```sql
   CALL getFriendList(1);
   ```

5. **`getLatestMessage` Stored Procedure:**
   - **Function:** Retrieves the latest message for a specific user.

   ```sql
   CALL getLatestMessage(1);
   ```

## Queries

1. **Retrieve all users and their friendships:**

   ```sql
   SELECT u.ID AS UserID, u.Username, u.Email, f.FriendID, fu.Username AS FriendUsername, fu.Email AS FriendEmail
   FROM users u
   JOIN friends f ON u.ID = f.ID
   JOIN users fu ON f.FriendID = fu.ID;
   ```

   **Example Output:**
   | UserID | Username | Email              | FriendID | FriendUsername | FriendEmail         |
   |--------|----------|--------------------|----------|-----------------|---------------------|
   | 1      | Sudhanshu | sudhanshu@email.com    | 2        | Sheetal           | sheetal@email.com    |
   | 1      | Sudhanshu | sudhanshu@email.com    | 3        | Arun           | arun@email.com    |
   | 2      | Sheetal    | sheetal@email.com    | 1        | Sudhanshu           | sudhanshu@email.com    |
   | 3      | Arun    | arun@email.com    | 1        | Sudhanshu           | sudhanshu@email.com    |

2. **Fetch messages sent by a specific user with sender and receiver details:**

   ```sql
   SELECT m.ID AS MessageID, m.FROMUID AS SenderID, u1.Username AS SenderUsername,
          m.ToUID AS ReceiverID, u2.Username AS ReceiverUsername, m.SentDt AS SentDateTime, m.MessageText
   FROM messages m
   JOIN users u1 ON m.FROMUID = u1.ID
   JOIN users u2 ON m.ToUID = u2.ID
   WHERE m.FROMUID = 1;
   ```

   **Example Output:**
   | MessageID | SenderID | SenderUsername | ReceiverID | ReceiverUsername | SentDateTime      | MessageText         |
   |-----------|----------|-----------------|------------|------------------|-------------------|---------------------|
   | 1         | 1        | Sudhanshu           | 2          | Sheetal            | 2023-01-01 12:00  | Hello, Sheetal!      |
   | 2         | 1        | Sudhanshu           | 3          | Arun              | 2023-01-02 14:30  | Hi, Sudhanshu!         |

3. **Obtain all messages exchanged between friends:**

   ```sql
   SELECT m.ID AS MessageID, m.FROMUID, m.ToUID, m

    .SentDt, m.MessageText
   FROM messages m
   JOIN friends f ON (m.FROMUID = f.ID AND m.ToUID = f.FriendID) OR (m.FROMUID = f.FriendID AND m.ToUID = f.ID);
   ```

   **Example Output:**
   | MessageID | SenderID | ReceiverID | SentDateTime      | MessageText         |
   |-----------|----------|------------|-------------------|---------------------|
   | 1         | 1        | 2          | 2023-01-01 12:00  | Hello, Sheetal!      |
   | 2         | 2        | 1          | 2023-01-02 14:30  | Hi, Sudhanshu!         |

4. **Identify unread messages for a specific user:**

   ```sql
   SELECT m.ID AS MessageID, m.FROMUID, u.Username AS SenderUsername, m.ToUID, m.SentDt AS SentDateTime, m.MessageText
   FROM messages m
   JOIN users u ON m.FROMUID = u.ID
   WHERE m.ToUID = 1 AND m.ReadStatus = 'Unread';
   ```

   **Example Output:**
   | MessageID | SenderID | SenderUsername | ReceiverID | SentDateTime      | MessageText         |
   |-----------|----------|-----------------|------------|-------------------|---------------------|
   | 3         | 3        | Arun           | 1          | 2023-01-03 10:45  | Unread message     |
   

5. **List users with a specific status:**

   ```sql
   SELECT ID AS UserID, Username, Email, Status
   FROM users
   WHERE Status = 'Active';
   ```

   **Example Output:**
   | UserID | Username | Email              | Status  |
   |--------|----------|--------------------|---------|
   | 1      | Sudhanshu    | sudhanshu@email.com    | Active  |
   | 2      | Sheetal    | sheetal@email.com    | Active  |
   

6. **Retrieve messages sent by users with a specific status:**

   ```sql
   SELECT m.ID AS MessageID, m.FROMUID, u.Username AS SenderUsername, m.ToUID, m.SentDt AS SentDateTime, m.MessageText
   FROM messages
   JOIN users u ON m.FROMUID = u.ID
   WHERE u.Status = 'Active';
   ```

   **Example Output:**
   | MessageID | SenderID | SenderUsername | ReceiverID | SentDateTime      | MessageText         |
   |-----------|----------|-----------------|------------|-------------------|---------------------|
   | 1         | 1        | Sudhanshu           | 2          | 2023-01-01 12:00  | Hello, Sheetal!      |
   | 2         | 2        | Sheetal           | 1          | 2023-01-02 14:30  | Hi, Sudhanshu!         |
   | 3         | 3        | Arun           | 1          | 2023-01-03 10:45  | Unread message     |

---

🌟 **Thank you for exploring the Chat Application Model Database!** 🚀

We believe in the magic of connecting people through technology. May your coding journey be as smooth as a well-optimized SQL query and your friendships as resilient as a robust database schema.

Feel free to reach out for any queries, collaborations, or just to share your success stories. Happy coding, and may your code always compile without errors!

Keep sparking creativity, keep building connections! 🌐✨

---












