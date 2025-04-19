// In-memory implementation for Guide Genie API
// Used as a fallback until Firebase integration is fully resolved

// Import sample data
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

// API handlers

// Get all games
async function getGames() {
  return games;
}

// Get a single game by ID
async function getGameById(id) {
  const gameId = parseInt(id);
  return games.find(game => game.id === gameId);
}

// Add a new guide to a game
async function addGuide(gameId, guideData) {
  const game = games.find(g => g.id === parseInt(gameId));
  if (!game) {
    throw new Error(`Game with ID ${gameId} not found`);
  }
  
  // Generate a new guide ID
  const maxGuideId = Math.max(...game.guides.map(g => g.id), 0);
  const newGuide = {
    id: maxGuideId + 1,
    title: guideData.title,
    author: guideData.author,
    content: guideData.content || '',
    likes: 0,
    date: new Date().toISOString().split('T')[0] // YYYY-MM-DD format
  };
  
  // Add the new guide to the game
  game.guides.push(newGuide);
  
  return newGuide;
}

// Add a new tier list to a game
async function addTierList(gameId, tierListData) {
  const game = games.find(g => g.id === parseInt(gameId));
  if (!game) {
    throw new Error(`Game with ID ${gameId} not found`);
  }
  
  // Generate a new tier list ID
  const maxTierListId = Math.max(...game.tierLists.map(t => t.id), 0);
  const newTierList = {
    id: maxTierListId + 1,
    title: tierListData.title,
    author: tierListData.author,
    content: tierListData.content || '',
    votes: 0
  };
  
  // Add the new tier list to the game
  game.tierLists.push(newTierList);
  
  return newTierList;
}

module.exports = {
  getGames,
  getGameById,
  addGuide,
  addTierList
};