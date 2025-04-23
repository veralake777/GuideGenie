const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files from web_demo/web
app.use(express.static(path.join(__dirname, '../web_demo/web')));

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Sample data for games
const games = [
  { 
    id: 1, 
    name: 'Fortnite', 
    iconUrl: '/images/fortnite.jpg',
    description: 'Battle royale game with building mechanics',
    guides: [
      { id: 101, title: 'Building Tips for Beginners', author: 'BuildMaster' },
      { id: 102, title: 'Advanced Weapon Loadouts', author: 'WeaponExpert' }
    ]
  },
  { 
    id: 2, 
    name: 'League of Legends', 
    iconUrl: '/images/lol.jpg',
    description: 'Multiplayer online battle arena',
    guides: [
      { id: 201, title: 'Jungle Pathing Guide', author: 'JunglePro' },
      { id: 202, title: 'Ward Placement Strategy', author: 'VisionMaster' }
    ]
  },
  { 
    id: 3, 
    name: 'Valorant', 
    iconUrl: '/images/valorant.jpg',
    description: 'Tactical shooter with unique agent abilities',
    guides: [
      { id: 301, title: 'Aim Training Routine', author: 'HeadshotKing' },
      { id: 302, title: 'Agent Tier List', author: 'TacticalGenius' }
    ]
  }
];

// Game API routes
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

// Fallback route for any other request
app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../web_demo/web/test.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});