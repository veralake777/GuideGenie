const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const querystring = require('querystring');
require('dotenv').config();

// Import Firebase database services
const firebaseDb = require('./firebase-db');

const PORT = process.env.PORT || 5000;

// Function to parse JSON body from requests
function parseBody(req) {
  return new Promise((resolve, reject) => {
    if (req.method !== 'POST' && req.method !== 'PUT') {
      return resolve({});
    }
    
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const parsedBody = body ? JSON.parse(body) : {};
        resolve(parsedBody);
      } catch (error) {
        reject(error);
      }
    });
    
    req.on('error', (err) => {
      reject(err);
    });
  });
}

// Sample data for games
const games = [
  { 
    id: 1, 
    name: 'Fortnite', 
    description: 'Battle royale game with building mechanics',
    category: 'Battle Royale',
    publisher: 'Epic Games',
    releaseYear: 2017,
    popularity: 90,
    guides: [
      { id: 101, title: 'Building Tips for Beginners', author: 'BuildMaster', likes: 342, date: '2023-11-12' },
      { id: 102, title: 'Advanced Weapon Loadouts', author: 'WeaponExpert', likes: 218, date: '2023-10-05' },
      { id: 103, title: 'Season 9 Meta Analysis', author: 'MetaGuru', likes: 560, date: '2024-02-20' }
    ],
    tierLists: [
      { id: 901, title: 'Season 9 Weapon Tier List', author: 'ProGamer123', votes: 1250 },
      { id: 902, title: 'Current Meta POI Rankings', author: 'MapMaster', votes: 850 }
    ]
  },
  { 
    id: 2, 
    name: 'League of Legends', 
    description: 'Multiplayer online battle arena',
    category: 'MOBA',
    publisher: 'Riot Games',
    releaseYear: 2009,
    popularity: 95,
    guides: [
      { id: 201, title: 'Jungle Pathing Guide', author: 'JunglePro', likes: 876, date: '2023-12-15' },
      { id: 202, title: 'Ward Placement Strategy', author: 'VisionMaster', likes: 654, date: '2024-01-10' },
      { id: 203, title: 'Support Role Macro Guide', author: 'SupportLife', likes: 432, date: '2024-03-05' }
    ],
    tierLists: [
      { id: 801, title: 'Champion Tier List Patch 14.5', author: 'LeagueMaster', votes: 3200 },
      { id: 802, title: 'Best ADCs Current Meta', author: 'ADCMain99', votes: 1850 }
    ]
  },
  { 
    id: 3, 
    name: 'Valorant', 
    description: 'Tactical shooter with unique agent abilities',
    category: 'Tactical FPS',
    publisher: 'Riot Games',
    releaseYear: 2020,
    popularity: 88,
    guides: [
      { id: 301, title: 'Aim Training Routine', author: 'HeadshotKing', likes: 987, date: '2023-11-28' },
      { id: 302, title: 'Agent Tier List', author: 'TacticalGenius', likes: 765, date: '2024-02-15' },
      { id: 303, title: 'Economy Management Guide', author: 'EconoMaster', likes: 546, date: '2024-01-20' }
    ],
    tierLists: [
      { id: 701, title: 'Agent Tier List Episode 7', author: 'ValMaster', votes: 2800 },
      { id: 702, title: 'Weapon Rankings by Map', author: 'GunGuru', votes: 1650 }
    ]
  },
  {
    id: 4,
    name: 'Street Fighter 6',
    description: 'Competitive fighting game with diverse character roster',
    category: 'Fighting',
    publisher: 'Capcom',
    releaseYear: 2023,
    popularity: 82,
    guides: [
      { id: 401, title: 'Frame Data Explained', author: 'FighterPhysics', likes: 645, date: '2023-10-18' },
      { id: 402, title: 'Basic Combo Guide', author: 'ComboKing', likes: 834, date: '2023-09-25' },
      { id: 403, title: 'Advanced Mind Games', author: 'MindMaster', likes: 420, date: '2024-01-05' }
    ],
    tierLists: [
      { id: 601, title: 'Character Tier List Season 2', author: 'FGCMaster', votes: 1900 },
      { id: 602, title: 'Move Tier List', author: 'FrameData', votes: 750 }
    ]
  },
  {
    id: 5,
    name: 'Call of Duty',
    description: 'First-person shooter series with modern military themes',
    category: 'FPS',
    publisher: 'Activision',
    releaseYear: 2003,
    popularity: 92,
    guides: [
      { id: 501, title: 'Warzone Loadout Guide', author: 'LoadoutKing', likes: 1200, date: '2024-01-10' },
      { id: 502, title: 'Movement Mechanics Tutorial', author: 'MovementGod', likes: 980, date: '2023-12-20' },
      { id: 503, title: 'Map Callouts Guide', author: 'MapMaster', likes: 765, date: '2024-02-18' }
    ],
    tierLists: [
      { id: 501, title: 'Weapon Meta Tier List', author: 'GunExpert', votes: 4500 },
      { id: 502, title: 'Best Perk Combinations', author: 'PerkPro', votes: 2300 }
    ]
  },
  {
    id: 6,
    name: 'Warzone',
    description: 'Free-to-play battle royale mode for Call of Duty',
    category: 'Battle Royale',
    publisher: 'Activision',
    releaseYear: 2020,
    popularity: 89,
    guides: [
      { id: 601, title: 'Rebirth Island Drop Spots', author: 'RebirthGod', likes: 890, date: '2024-02-05' },
      { id: 602, title: 'Best Controller Settings', author: 'ControllerPro', likes: 720, date: '2023-11-30' },
      { id: 603, title: 'Long Range Meta', author: 'SnipeMaster', likes: 650, date: '2024-03-10' }
    ],
    tierLists: [
      { id: 401, title: 'Season 4 Weapon Tier List', author: 'WarzonePro', votes: 5600 },
      { id: 402, title: 'Best Tactical Equipment', author: 'TacGod', votes: 2100 }
    ]
  },
  {
    id: 7,
    name: 'Marvel Rivals',
    description: 'Team-based hero shooter featuring Marvel characters',
    category: 'Hero Shooter',
    publisher: 'NetEase Games',
    releaseYear: 2023,
    popularity: 78,
    guides: [
      { id: 701, title: 'Beginner Hero Picks', author: 'MarvelMaster', likes: 540, date: '2023-10-15' },
      { id: 702, title: 'Team Composition Guide', author: 'TeamTactician', likes: 420, date: '2024-01-25' },
      { id: 703, title: 'Map Objectives Breakdown', author: 'ObjectivePro', likes: 380, date: '2024-02-28' }
    ],
    tierLists: [
      { id: 301, title: 'Hero Power Rankings', author: 'MarvelExpert', votes: 1800 },
      { id: 302, title: 'Team Comp Tier List', author: 'StrategyMaster', votes: 950 }
    ]
  }
];

// Helper function to serve static files
function serveStaticFile(res, filePath, contentType) {
  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404);
        res.end('File not found');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
}

const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  
  console.log(`Request received: ${pathname}`);
  
  // Initialize the database with sample data on first request
  if (!global.dbInitialized) {
    try {
      console.log('Initializing Firebase database with sample data...');
      await firebaseDb.initializeDatabase(games);
      global.dbInitialized = true;
      console.log('Firebase database initialization complete.');
    } catch (error) {
      console.error('Error initializing Firebase database:', error);
      // Continue anyway to serve from in-memory data as fallback
    }
  }
  
  // Set CORS headers for all responses
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }
  
  // API routes
  if (pathname === '/api/games') {
    try {
      const allGames = await firebaseDb.getGames();
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(allGames));
    } catch (error) {
      console.error('Error fetching games from Firebase:', error);
      // Fallback to in-memory data
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(games));
    }
  } 
  else if (pathname.match(/^\/api\/games\/\d+$/)) {
    try {
      const id = parseInt(pathname.split('/').pop());
      
      const game = await firebaseDb.getGameById(id);
      
      if (game) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(game));
      } else {
        // Try to find the game in memory as fallback
        const memoryGame = games.find(g => g.id === id);
        
        if (memoryGame) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(memoryGame));
        } else {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Game not found' }));
        }
      }
    } catch (error) {
      console.error(`Error fetching game from Firebase:`, error);
      // Fallback to in-memory data
      const id = parseInt(pathname.split('/').pop());
      const memoryGame = games.find(g => g.id === id);
      
      if (memoryGame) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(memoryGame));
      } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Game not found' }));
      }
    }
  }
  else if (pathname === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'ok', 
      message: 'Server is running',
      firebase: global.dbInitialized ? 'connected' : 'not connected' 
    }));
  }
  // Add new guide
  else if (pathname.match(/^\/api\/games\/\d+\/guides$/) && req.method === 'POST') {
    try {
      // Get the game ID from the URL
      const gameId = parseInt(pathname.split('/')[3]);
      
      // Parse the request body
      const body = await parseBody(req);
      
      // Validate the required fields
      if (!body.title || !body.author) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Title and author are required' }));
        return;
      }
      
      try {
        // Save to Firebase
        const newGuide = await firebaseDb.addGuide(gameId, body);
        
        // Return the new guide
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newGuide));
      } catch (error) {
        console.error(`Error adding guide to Firebase:`, error);
        
        // Fallback to in-memory data
        const game = games.find(g => g.id === gameId);
        
        if (!game) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Game not found' }));
          return;
        }
        
        // Generate a new guide ID
        const maxGuideId = Math.max(...game.guides.map(g => g.id), 0);
        const newGuide = {
          id: maxGuideId + 1,
          title: body.title,
          author: body.author,
          content: body.content || '',
          likes: 0,
          date: new Date().toISOString().split('T')[0] // YYYY-MM-DD format
        };
        
        // Add the new guide to the game
        game.guides.push(newGuide);
        
        // Return the new guide
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newGuide));
      }
    } catch (error) {
      console.error('Error processing guide request:', error);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Invalid request' }));
    }
  }
  // Add new tier list
  else if (pathname.match(/^\/api\/games\/\d+\/tierlists$/) && req.method === 'POST') {
    try {
      // Get the game ID from the URL
      const gameId = parseInt(pathname.split('/')[3]);
      
      // Parse the request body
      const body = await parseBody(req);
      
      // Validate the required fields
      if (!body.title || !body.author) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Title and author are required' }));
        return;
      }
      
      try {
        // Save to Firebase
        const newTierList = await firebaseDb.addTierList(gameId, body);
        
        // Return the new tier list
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newTierList));
      } catch (error) {
        console.error(`Error adding tier list to Firebase:`, error);
        
        // Fallback to in-memory data
        const game = games.find(g => g.id === gameId);
        
        if (!game) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Game not found' }));
          return;
        }
        
        // Generate a new tier list ID
        const maxTierListId = Math.max(...game.tierLists.map(t => t.id), 0);
        const newTierList = {
          id: maxTierListId + 1,
          title: body.title,
          author: body.author,
          content: body.content || '',
          votes: 0
        };
        
        // Add the new tier list to the game
        game.tierLists.push(newTierList);
        
        // Return the new tier list
        res.writeHead(201, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(newTierList));
      }
    } catch (error) {
      console.error('Error processing tier list request:', error);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Invalid request' }));
    }
  }
  // Handle static files or default to test.html
  else {
    // Check if the request is for a specific file in the web directory
    const webFilePath = path.join(__dirname, '../web_demo/web', pathname);
    
    if (pathname === '/' || pathname === '/index.html') {
      serveStaticFile(res, path.join(__dirname, '../web_demo/web/test.html'), 'text/html');
    }
    else if (fs.existsSync(webFilePath) && fs.statSync(webFilePath).isFile()) {
      // Determine content type based on file extension
      const ext = path.extname(pathname).toLowerCase();
      let contentType = 'text/html';
      
      switch (ext) {
        case '.js':
          contentType = 'text/javascript';
          break;
        case '.css':
          contentType = 'text/css';
          break;
        case '.json':
          contentType = 'application/json';
          break;
        case '.png':
          contentType = 'image/png';
          break;
        case '.jpg':
          contentType = 'image/jpg';
          break;
        case '.svg':
          contentType = 'image/svg+xml';
          break;
      }
      
      serveStaticFile(res, webFilePath, contentType);
    } 
    else {
      // Default to serving the test.html for any other paths
      serveStaticFile(res, path.join(__dirname, '../web_demo/web/test.html'), 'text/html');
    }
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});