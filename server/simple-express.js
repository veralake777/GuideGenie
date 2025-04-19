const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Sample data for games
const games = [
  { 
    id: 1, 
    name: 'Fortnite', 
    description: 'Battle royale game with building mechanics',
    guides: [
      { id: 101, title: 'Building Tips for Beginners', author: 'BuildMaster' },
      { id: 102, title: 'Advanced Weapon Loadouts', author: 'WeaponExpert' }
    ]
  },
  { 
    id: 2, 
    name: 'League of Legends', 
    description: 'Multiplayer online battle arena',
    guides: [
      { id: 201, title: 'Jungle Pathing Guide', author: 'JunglePro' },
      { id: 202, title: 'Ward Placement Strategy', author: 'VisionMaster' }
    ]
  },
  { 
    id: 3, 
    name: 'Valorant', 
    description: 'Tactical shooter with unique agent abilities',
    guides: [
      { id: 301, title: 'Aim Training Routine', author: 'HeadshotKing' },
      { id: 302, title: 'Agent Tier List', author: 'TacticalGenius' }
    ]
  }
];

// Serve static files
app.use(express.static(path.join(__dirname, '../web_demo/web')));

// API endpoints
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

app.get('/api/games', (req, res) => {
  res.json(games);
});

app.get('/api/games/:id', (req, res) => {
  const gameId = parseInt(req.params.id);
  const game = games.find(g => g.id === gameId);
  
  if (!game) {
    return res.status(404).json({ error: 'Game not found' });
  }
  
  res.json(game);
});

// Default route to serve the main HTML file
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../web_demo/web/test.html'));
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});