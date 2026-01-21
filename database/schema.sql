-- USERS
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  telegram_id INTEGER NOT NULL UNIQUE,
  username TEXT,
  first_name TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- GROUPS
CREATE TABLE groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  telegram_group_id INTEGER NOT NULL UNIQUE,
  name TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- REQUIRED CHANNELS (configuração)
CREATE TABLE required_channels (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  telegram_channel_id INTEGER NOT NULL UNIQUE,
  name TEXT,
  active INTEGER DEFAULT 1
);

-- JOIN EVENTS
CREATE TABLE join_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  group_id INTEGER NOT NULL,
  joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

CREATE INDEX idx_join_events_group_date
ON join_events (group_id, joined_at);

-- VERIFICATION EVENTS
CREATE TABLE verification_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  group_id INTEGER NOT NULL,
  verified_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  result INTEGER NOT NULL, -- 1 = PASS | 0 = FAIL
  fail_reason TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

CREATE INDEX idx_verification_group_date
ON verification_events (group_id, verified_at);

-- CHANNEL CHECKS (estado no momento da verificação)
CREATE TABLE channel_checks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  verification_event_id INTEGER NOT NULL,
  channel_id INTEGER NOT NULL,
  is_member INTEGER NOT NULL, -- 1 = sim | 0 = não
  FOREIGN KEY (verification_event_id) REFERENCES verification_events(id),
  FOREIGN KEY (channel_id) REFERENCES required_channels(id)
);

CREATE INDEX idx_channel_checks_channel_result
ON channel_checks (channel_id, is_member);

-- PERMISSION EVENTS
CREATE TABLE permission_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  group_id INTEGER NOT NULL,
  action TEXT NOT NULL, -- MUTE | UNMUTE
  reason TEXT,
  executed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (group_id) REFERENCES groups(id)
);

CREATE INDEX idx_permission_group_action
ON permission_events (group_id, action);
