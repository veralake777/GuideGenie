import { pgTable, serial, text, integer, timestamp, pgEnum } from "drizzle-orm/pg-core";

// Game Status Enum
export const gameStatusEnum = pgEnum('game_status', ['active', 'inactive', 'upcoming']);

// Games Table
export const games = pgTable('games', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  description: text('description'),
  icon_url: text('icon_url'),
  banner_url: text('banner_url'),
  status: gameStatusEnum('status').default('active'),
  release_date: timestamp('release_date'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow(),
});

export type Game = typeof games.$inferSelect;
export type InsertGame = typeof games.$inferInsert;

// User Role Enum
export const userRoleEnum = pgEnum('user_role', ['user', 'admin']);

// Users Table
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  username: text('username').notNull().unique(),
  email: text('email').notNull().unique(),
  password_hash: text('password_hash').notNull(),
  display_name: text('display_name'),
  avatar_url: text('avatar_url'),
  bio: text('bio'),
  role: userRoleEnum('role').default('user'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow(),
});

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;

// Guides Table
export const guides = pgTable('guides', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  content: text('content').notNull(),
  game_id: integer('game_id').notNull().references(() => games.id),
  author_id: integer('author_id').notNull().references(() => users.id),
  upvotes: integer('upvotes').default(0),
  downvotes: integer('downvotes').default(0),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow(),
});

export type Guide = typeof guides.$inferSelect;
export type InsertGuide = typeof guides.$inferInsert;

// Comments Table
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  content: text('content').notNull(),
  guide_id: integer('guide_id').notNull().references(() => guides.id),
  author_id: integer('author_id').notNull().references(() => users.id),
  upvotes: integer('upvotes').default(0),
  downvotes: integer('downvotes').default(0),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow(),
});

export type Comment = typeof comments.$inferSelect;
export type InsertComment = typeof comments.$inferInsert;