**Pulse Chat** screen list, organized by priority.

---

## Phase 1 — Core Screens (MVP)

### 1. Splash Screen

**Purpose:** App initialization

Elements:

* Pulse logo animation
* Firebase initialization
* Authentication check

Flow:

```
Splash
  ↓
Logged in → Home
Not logged in → Welcome/Login
```

---

### 2. Welcome Screen

**Purpose:** First-time introduction

Elements:

* App logo
* Tagline: "Stay in sync"
* Get Started button
* Login button

---

### 3. Login Screen

Elements:

* Email field
* Password field
* Login button
* Google Sign-In
* Forgot password
* Register link

---

### 4. Register Screen

Elements:

* Name
* Email
* Password
* Confirm password
* Profile photo upload

---

### 5. Forgot Password Screen

Elements:

* Email input
* Reset password button

---

# Main App Screens

## 6. Home Screen (Chat List)

This is the main screen.

Elements:

```
--------------------------------
Pulse                 🔍  ⚙️

Pinned Chats

John
Hey, are you free?
10:30 AM

Sarah
See you tomorrow
Yesterday

--------------------------------

        + New Chat
--------------------------------
```

Features:

* Recent conversations
* Last message preview
* Unread count
* Online indicator
* Search

---

## 7. Chat Screen (Most Important)

The core screen.

Elements:

```
John                  🟢 ⋮

        Hey!
        
              Hello 👋
              
        How are you?

[ + ] [Type message...] 🎤
```

Features:

* Send messages
* Receive messages
* Typing indicator
* Online status
* Read receipts
* Reply
* Reactions
* Attachments

---

## 8. New Chat Screen

Purpose:
Start a conversation.

Elements:

* Search users
* User list
* Online status
* Start chat button

---

# Profile & Settings

## 9. My Profile Screen

Elements:

* Profile picture
* Name
* Username
* Bio
* Email
* Edit button

---

## 10. Edit Profile Screen

Features:

* Change photo
* Change name
* Update bio
* Save changes

---

## 11. Settings Screen

Sections:

### Account

* Profile
* Privacy

### Appearance

* Dark mode
* Theme

### Notifications

* Message notifications
* Sound

### Other

* Help
* About
* Logout

---

# Advanced Chat Features

## 12. Media Gallery Screen

Shows:

```
Photos | Videos | Files
```

Features:

* Images shared in chat
* Videos
* Documents

---

## 13. Chat Details Screen

Opened from chat menu.

Elements:

```
John

🟢 Online

Media
Files
Search Messages

Mute Notifications

Block User

Clear Chat
```

---

## 14. Message Search Screen

Features:

Search:

```
"flutter"

Results:

John:
"I am learning Flutter"
```

---

## 15. Group Creation Screen

For group chats.

Steps:

```
Select Members
       ↓
Group Info
       ↓
Create Group
```

---

## 16. Group Details Screen

Features:

* Group photo
* Members list
* Admin controls
* Leave group
* Add members

---

# Notification / System Screens

## 17. Notifications Screen

Optional but nice.

Shows:

```
John sent a message
Sarah mentioned you
```

---

## 18. Blocked Users Screen

Features:

* Block list
* Unblock users

---

## 19. Privacy Screen

Features:

* Last seen visibility
* Profile photo visibility
* Read receipts toggle

---

# Error / Empty States

These make the app feel production quality.

## 20. No Internet Screen

```
No connection

Check your internet and try again
```

---

## 21. Empty Chat Screen

```
No conversations yet

Start a new chat
```

---

## 22. Error Screen

For:

* Firebase errors
* Failed uploads
* Authentication errors

---

# Optional "Wow Factor" Screens

These are great portfolio additions.

### 23. Voice Message Recorder Screen

* Recording animation
* Waveform
* Timer

---

### 24. Image Preview Screen

Before sending:

* Crop
* Add caption
* Send

---

### 25. Status/Stories Screen

Like WhatsApp:

* Add status
* View friends' status

---

### 26. Calls Screen

For advanced:

* Audio calls
* Video calls

(using WebRTC or a service)

---

## Final Screen Set

1. Splash
2. Login
3. Register
4. Home Chat List
5. Chat Screen
6. New Chat
7. Profile
8. Edit Profile
9. Settings
10. Chat Details
11. Media Gallery
12. Search Messages
13. Group Creation
14. Group Details
15. Privacy Settings

