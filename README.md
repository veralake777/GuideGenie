# Guide Genie

A Flutter-based mobile app for gamers to quickly access tier lists, loadouts, and strategies for popular games.

## Overview

Guide Genie is a cross-platform mobile application designed for gamers who want quick and easy access to the latest meta information, strategies, tier lists, and loadouts for their favorite games. The app focuses on providing a centralized hub for game guides across multiple popular titles including Fortnite, League of Legends, Valorant, Street Fighter, Call of Duty, Warzone, and Marvel Rivals.

## Features

- **Game Guides**: Access comprehensive guides for popular games
- **Tier Lists**: View up-to-date tier lists for characters, weapons, and more
- **Loadout Recommendations**: Discover optimal loadouts and builds
- **Strategy Guides**: Learn advanced strategies from experienced players
- **User Contributions**: Create and share your own guides with the community
- **Favorites**: Save your preferred guides for quick access
- **Dark Mode**: Toggle between light and dark themes for comfortable viewing

## Supported Games

- Fortnite
- League of Legends
- Valorant
- Street Fighter
- Call of Duty
- Warzone
- Marvel Rivals

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Node.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **Storage**: Shared Preferences for local storage
- **HTTP Client**: HTTP package for API requests
- **Authentication**: JWT-based authentication

## Project Structure

```
lib/                  # Flutter application code
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API and storage services
├── utils/            # Utility functions and constants
├── widgets/          # Reusable UI components
└── main.dart         # Application entry point

server/               # Backend server code
├── shared/           # Shared code between server and client
│   └── schema.ts     # Database schema definitions
├── db.ts             # Database connection setup
├── storage.ts        # Data access layer
└── index.ts          # Server entry point
```

## Database Schema

The application uses a PostgreSQL database with the following main tables:

- **users**: User accounts and authentication information
- **games**: Information about games (title, genre, rating, etc.)
- **posts**: Guide posts created by users
- **comments**: User comments on guide posts
- **bookmarks**: User bookmarks for favorite guides

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- iOS simulator or Android emulator (for testing)
- Node.js (16.x or later) for running the server
- PostgreSQL database

### Application Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/guide_genie.git
   ```

2. Navigate to the project directory:
   ```
   cd guide_genie
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

### Server Setup

The application uses a Node.js backend with PostgreSQL database and Drizzle ORM.

1. Install required packages:
   ```
   npm install @neondatabase/serverless drizzle-orm ws
   ```

2. Set up environment variables:
   Create a `.env` file in the root directory with the following variables:
   ```
   DATABASE_URL=postgresql://username:password@localhost:5432/guidegenie
   DISABLE_DATABASE_IN_WEB=false
   USE_MOCK_DATA=false
   ```

3. Set up PostgreSQL:
   - Install PostgreSQL
   - Create a database named 'guidegenie'
   - The connection string follows the format: `postgresql://username:password@host:port/database_name`

4. Create the server directory and database initialization files:
   ```
   mkdir -p server/shared
   ```

5. Create `server/db.ts` with the following content:
   ```typescript
   import { Pool, neonConfig } from '@neondatabase/serverless';
   import { drizzle } from 'drizzle-orm/neon-serverless';
   import ws from "ws";
   import * as schema from "@shared/schema";

   neonConfig.webSocketConstructor = ws;

   if (!process.env.DATABASE_URL) {
     throw new Error(
       "DATABASE_URL must be set. Did you forget to provision a database?",
     );
   }

   export const pool = new Pool({ connectionString: process.env.DATABASE_URL });
   export const db = drizzle({ client: pool, schema });
   ```

6. Create your database schema in `shared/schema.ts`. Here's a basic example:
   ```typescript
   import { pgTable, serial, text, varchar, boolean, timestamp, integer } from 'drizzle-orm/pg-core';

   // Users table
   export const users = pgTable('users', {
     id: serial('id').primaryKey(),
     username: varchar('username', { length: 50 }).notNull().unique(),
     email: varchar('email', { length: 100 }).notNull().unique(),
     passwordHash: text('password_hash').notNull(),
     salt: text('salt').notNull(),
     avatarUrl: text('avatar_url'),
     createdAt: timestamp('created_at').defaultNow().notNull(),
     updatedAt: timestamp('updated_at').defaultNow().notNull(),
   });

   // Games table
   export const games = pgTable('games', {
     id: serial('id').primaryKey(),
     title: varchar('title', { length: 100 }).notNull(),
     genre: varchar('genre', { length: 50 }).notNull(),
     imageUrl: text('image_url').notNull(),
     description: text('description').notNull(),
     rating: integer('rating').default(0),
     isFeatured: boolean('is_featured').default(false),
     developer: varchar('developer', { length: 100 }),
     publisher: varchar('publisher', { length: 100 }),
     createdAt: timestamp('created_at').defaultNow().notNull(),
   });
   ```

7. Set up database migrations with Drizzle:
   ```
   npm install -D drizzle-kit
   ```

8. Add the following script to your package.json:
   ```json
   "scripts": {
     "db:push": "drizzle-kit push:pg",
     "db:studio": "drizzle-kit studio"
   }
   ```

9. Create a `drizzle.config.ts` file in the root directory:
   ```typescript
   import type { Config } from 'drizzle-kit';
   import 'dotenv/config';

   export default {
     schema: './shared/schema.ts',
     out: './drizzle',
     driver: 'pg',
     dbCredentials: {
       connectionString: process.env.DATABASE_URL!,
     },
   } satisfies Config;
   ```

10. Push your schema to the database:
    ```
    npm run db:push
    ```

11. Start the server:
    ```
    ts-node server/index.ts
    ```
   
12. Create a `server/storage.ts` file for database operations:
    ```typescript
    import { users, type User, type InsertUser } from "@shared/schema";
    import { db } from "./db";
    import { eq } from "drizzle-orm";

    export interface IStorage {
      getUser(id: number): Promise<User | undefined>;
      getUserByUsername(username: string): Promise<User | undefined>;
      createUser(insertUser: InsertUser): Promise<User>;
    }

    export class DatabaseStorage implements IStorage {
      async getUser(id: number): Promise<User | undefined> {
        const [user] = await db.select().from(users).where(eq(users.id, id));
        return user || undefined;
      }

      async getUserByUsername(username: string): Promise<User | undefined> {
        const [user] = await db.select().from(users).where(eq(users.username, username));
        return user || undefined;
      }

      async createUser(insertUser: InsertUser): Promise<User> {
        const [user] = await db
          .insert(users)
          .values(insertUser)
          .returning();
        return user;
      }
    }

    export const storage = new DatabaseStorage();
    ```

13. Create a basic API server in `server/index.ts`:
    ```typescript
    import express from 'express';
    import { db } from './db';
    import { storage } from './storage';
    import cors from 'cors';
    import { games, users } from '@shared/schema';

    const app = express();
    const PORT = process.env.PORT || 8000;

    app.use(cors());
    app.use(express.json());

    // Health check endpoint
    app.get('/api/health', (req, res) => {
      res.json({ status: 'ok', timestamp: new Date() });
    });

    // Get all games
    app.get('/api/games', async (req, res) => {
      try {
        const allGames = await db.select().from(games);
        res.json(allGames);
      } catch (error) {
        console.error('Error fetching games:', error);
        res.status(500).json({ error: 'Failed to fetch games' });
      }
    });

    // Create new game
    app.post('/api/games', async (req, res) => {
      try {
        const gameData = req.body;
        const [newGame] = await db.insert(games).values(gameData).returning();
        res.status(201).json(newGame);
      } catch (error) {
        console.error('Error creating game:', error);
        res.status(500).json({ error: 'Failed to create game' });
      }
    });

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
    ```

14. Install Express.js and necessary dependencies:
    ```
    npm install express cors
    npm install -D @types/express @types/cors
    ```

15. The server should now connect to your PostgreSQL database with the Drizzle ORM
    
16. To view and manage your database, you can use Drizzle Studio:
    ```
    npm run db:studio
    ```

### Configuring the Flutter App to Connect to Your Local Server

1. Update the API service configuration:
   In `lib/services/api_service_new.dart`, set the base URL to point to your local server:
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```

2. If you're testing on an Android emulator and connecting to a server on your host machine, use:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   ```

3. For iOS simulators connecting to a local server, use:
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```

## Contributing

Contributions are welcome! Feel free to open issues and pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
