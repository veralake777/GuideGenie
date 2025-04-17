import express, { Request, Response } from 'express';
import { db } from './db';
import { storage } from './storage';
import cors from 'cors';
import { games, guides, users, comments } from '../shared/schema';
import { eq } from 'drizzle-orm';

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// === GAMES ENDPOINTS ===

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

// Get game by ID
app.get('/api/games/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const [game] = await db.select().from(games).where(eq(games.id, id));
    
    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }
    
    res.json(game);
  } catch (error) {
    console.error('Error fetching game:', error);
    res.status(500).json({ error: 'Failed to fetch game' });
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

// Update game
app.put('/api/games/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const gameData = req.body;
    
    const [updatedGame] = await db
      .update(games)
      .set(gameData)
      .where(eq(games.id, id))
      .returning();
    
    if (!updatedGame) {
      return res.status(404).json({ error: 'Game not found' });
    }
    
    res.json(updatedGame);
  } catch (error) {
    console.error('Error updating game:', error);
    res.status(500).json({ error: 'Failed to update game' });
  }
});

// Delete game
app.delete('/api/games/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    await db.delete(games).where(eq(games.id, id));
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting game:', error);
    res.status(500).json({ error: 'Failed to delete game' });
  }
});

// === GUIDES ENDPOINTS ===

// Get all guides
app.get('/api/guides', async (req, res) => {
  try {
    const allGuides = await db.select().from(guides);
    res.json(allGuides);
  } catch (error) {
    console.error('Error fetching guides:', error);
    res.status(500).json({ error: 'Failed to fetch guides' });
  }
});

// Get guides by game ID
app.get('/api/games/:gameId/guides', async (req, res) => {
  try {
    const gameId = parseInt(req.params.gameId);
    const gameGuides = await db
      .select()
      .from(guides)
      .where(eq(guides.game_id, gameId));
    
    res.json(gameGuides);
  } catch (error) {
    console.error('Error fetching guides for game:', error);
    res.status(500).json({ error: 'Failed to fetch guides for game' });
  }
});

// Get guide by ID
app.get('/api/guides/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const [guide] = await db.select().from(guides).where(eq(guides.id, id));
    
    if (!guide) {
      return res.status(404).json({ error: 'Guide not found' });
    }
    
    res.json(guide);
  } catch (error) {
    console.error('Error fetching guide:', error);
    res.status(500).json({ error: 'Failed to fetch guide' });
  }
});

// Create new guide
app.post('/api/guides', async (req, res) => {
  try {
    const guideData = req.body;
    const [newGuide] = await db.insert(guides).values(guideData).returning();
    res.status(201).json(newGuide);
  } catch (error) {
    console.error('Error creating guide:', error);
    res.status(500).json({ error: 'Failed to create guide' });
  }
});

// Update guide
app.put('/api/guides/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const guideData = req.body;
    
    const [updatedGuide] = await db
      .update(guides)
      .set(guideData)
      .where(eq(guides.id, id))
      .returning();
    
    if (!updatedGuide) {
      return res.status(404).json({ error: 'Guide not found' });
    }
    
    res.json(updatedGuide);
  } catch (error) {
    console.error('Error updating guide:', error);
    res.status(500).json({ error: 'Failed to update guide' });
  }
});

// Delete guide
app.delete('/api/guides/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    await db.delete(guides).where(eq(guides.id, id));
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting guide:', error);
    res.status(500).json({ error: 'Failed to delete guide' });
  }
});

// === USER ENDPOINTS ===

// Get user by ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const user = await storage.getUser(id);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Don't return password hash to client
    const { password_hash, ...safeUser } = user;
    res.json(safeUser);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Create new user
app.post('/api/users', async (req, res) => {
  try {
    const userData = req.body;
    const newUser = await storage.createUser(userData);
    
    // Don't return password hash to client
    const { password_hash, ...safeUser } = newUser;
    res.status(201).json(safeUser);
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});