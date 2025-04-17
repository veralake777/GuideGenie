import { Pool, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';
import ws from "ws";
import * as schema from "../shared/schema";

neonConfig.webSocketConstructor = ws;

// Use a default connection string for development if DATABASE_URL is not set
const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/guidegenie';

export const pool = new Pool({ connectionString });
export const db = drizzle(pool, { schema });
