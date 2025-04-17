const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Mock games data
const games = [
  {
    id: 1,
    name: 'Fortnite',
    description: 'A battle royale game with building mechanics',
    icon_url: '/assets/game_logos/fortnite.png',
    status: 'active'
  },
  {
    id: 2,
    name: 'League of Legends',
    description: 'A multiplayer online battle arena game',
    icon_url: '/assets/game_logos/lol.png',
    status: 'active'
  },
  {
    id: 3,
    name: 'Valorant',
    description: 'A tactical first-person shooter game',
    icon_url: '/assets/game_logos/valorant.png',
    status: 'active'
  }
];

// Get all games
app.get('/api/games', (req, res) => {
  res.json(games);
});

// Get game by ID
app.get('/api/games/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const game = games.find(g => g.id === id);
  
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }
  
  res.json(game);
});

// Create new game
app.post('/api/games', (req, res) => {
  const gameData = req.body;
  const newId = games.length > 0 ? Math.max(...games.map(g => g.id)) + 1 : 1;
  
  const newGame = {
    id: newId,
    ...gameData
  };
  
  games.push(newGame);
  res.status(201).json(newGame);
});

// Update game
app.put('/api/games/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const gameIndex = games.findIndex(g => g.id === id);
  
  if (gameIndex === -1) {
    return res.status(404).json({ error: 'Game not found' });
  }
  
  const updatedGame = {
    ...games[gameIndex],
    ...req.body
  };
  
  games[gameIndex] = updatedGame;
  res.json(updatedGame);
});

// Delete game
app.delete('/api/games/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const gameIndex = games.findIndex(g => g.id === id);
  
  if (gameIndex !== -1) {
    games.splice(gameIndex, 1);
  }
  
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});