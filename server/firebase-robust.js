// Robust Firebase implementation for Guide Genie API
const firebaseAdmin = require('./firebase-admin-setup');
const memoryApi = require('./api-handler');

// In-memory data to use as fallback
// Note: getGames() returns a Promise, so we need to handle it properly
let sampleGames = [];

// Initialize sample games data
(async () => {
  try {
    sampleGames = await memoryApi.getGames();
    console.log(`Loaded ${sampleGames.length} sample games from memory API`);
  } catch (error) {
    console.error('Error loading sample games:', error);
    sampleGames = [];
  }
})();

// Determine if we're using Firebase or memory storage
const useFirebase = firebaseAdmin.initialized && firebaseAdmin.db;

// Collection references - will be null if Firebase is not initialized
const db = firebaseAdmin.db;
const gamesCollection = useFirebase ? db.collection('games') : null;

console.log(`Using ${useFirebase ? 'Firebase' : 'in-memory'} storage for data`);

// Initialize the Firebase database with sample data if needed
async function initializeDatabase() {
  if (!useFirebase) {
    console.log('Firebase not initialized, skipping database initialization');
    return false;
  }
  
  try {
    console.log('Checking if Firebase database needs initialization...');
    
    // Check if the database already has data
    const gamesSnapshot = await gamesCollection.get();
    
    if (gamesSnapshot.empty) {
      console.log('Database is empty, initializing with sample data...');
      
      // Use a batch to add all games at once
      const batch = db.batch();
      
      // Add each game to the games collection
      for (const game of sampleGames) {
        const gameRef = gamesCollection.doc(game.id.toString());
        
        // Remove nested collections before saving
        const { guides, tierLists, ...gameData } = game;
        batch.set(gameRef, gameData);
      }
      
      // Commit the batch
      await batch.commit();
      console.log('Base game data written successfully');
      
      // Now add subcollections for each game
      for (const game of sampleGames) {
        const gameRef = gamesCollection.doc(game.id.toString());
        
        // Add guides subcollection
        const guidesRef = gameRef.collection('guides');
        const guidesBatch = db.batch();
        
        for (const guide of game.guides) {
          guidesBatch.set(guidesRef.doc(guide.id.toString()), guide);
        }
        
        await guidesBatch.commit();
        console.log(`Added ${game.guides.length} guides for ${game.name}`);
        
        // Add tierLists subcollection
        const tierListsRef = gameRef.collection('tierLists');
        const tierListsBatch = db.batch();
        
        for (const tierList of game.tierLists) {
          tierListsBatch.set(tierListsRef.doc(tierList.id.toString()), tierList);
        }
        
        await tierListsBatch.commit();
        console.log(`Added ${game.tierLists.length} tier lists for ${game.name}`);
      }
      
      console.log('Database initialization complete!');
      return true;
    } else {
      console.log(`Database already contains ${gamesSnapshot.size} games, skipping initialization`);
      return true;
    }
  } catch (error) {
    console.error('Error initializing database:', error);
    return false;
  }
}

// API Methods that attempt Firebase operations but fall back to in-memory if needed

// Get all games
async function getGames() {
  if (!useFirebase) {
    return sampleGames;
  }
  
  try {
    const gamesSnapshot = await gamesCollection.get();
    const games = [];
    
    // Process each game document
    for (const doc of gamesSnapshot.docs) {
      const game = doc.data();
      game.id = parseInt(doc.id);
      
      // Get guides subcollection
      const guidesSnapshot = await doc.ref.collection('guides').get();
      game.guides = [];
      guidesSnapshot.forEach(guideDoc => {
        const guide = guideDoc.data();
        guide.id = parseInt(guideDoc.id);
        game.guides.push(guide);
      });
      
      // Get tierLists subcollection
      const tierListsSnapshot = await doc.ref.collection('tierLists').get();
      game.tierLists = [];
      tierListsSnapshot.forEach(tierListDoc => {
        const tierList = tierListDoc.data();
        tierList.id = parseInt(tierListDoc.id);
        game.tierLists.push(tierList);
      });
      
      games.push(game);
    }
    
    return games;
  } catch (error) {
    console.error('Error getting games from Firebase:', error);
    // Fall back to in-memory data
    return sampleGames;
  }
}

// Get a single game by ID
async function getGameById(gameId) {
  if (!useFirebase) {
    return sampleGames.find(game => game.id === parseInt(gameId));
  }
  
  try {
    const gameDoc = await gamesCollection.doc(gameId.toString()).get();
    
    if (!gameDoc.exists) {
      return null;
    }
    
    const game = gameDoc.data();
    game.id = parseInt(gameDoc.id);
    
    // Get guides subcollection
    const guidesSnapshot = await gameDoc.ref.collection('guides').get();
    game.guides = [];
    guidesSnapshot.forEach(guideDoc => {
      const guide = guideDoc.data();
      guide.id = parseInt(guideDoc.id);
      game.guides.push(guide);
    });
    
    // Get tierLists subcollection
    const tierListsSnapshot = await gameDoc.ref.collection('tierLists').get();
    game.tierLists = [];
    tierListsSnapshot.forEach(tierListDoc => {
      const tierList = tierListDoc.data();
      tierList.id = parseInt(tierListDoc.id);
      game.tierLists.push(tierList);
    });
    
    return game;
  } catch (error) {
    console.error(`Error getting game ${gameId} from Firebase:`, error);
    // Fall back to in-memory data
    return sampleGames.find(game => game.id === parseInt(gameId));
  }
}

// Add a new guide to a game
async function addGuide(gameId, guideData) {
  // First attempt to use in-memory API to have the data regardless
  const memoryResult = await memoryApi.addGuide(gameId, guideData);
  
  if (!useFirebase) {
    return memoryResult;
  }
  
  try {
    // Now try to save to Firebase as well
    const gameDoc = await gamesCollection.doc(gameId.toString()).get();
    
    if (!gameDoc.exists) {
      throw new Error(`Game with ID ${gameId} not found`);
    }
    
    const guidesRef = gameDoc.ref.collection('guides');
    
    // Get the next guide ID (same as what the memory API generated)
    const newGuide = {
      id: memoryResult.id,
      title: guideData.title,
      author: guideData.author,
      content: guideData.content || '',
      likes: 0,
      date: new Date().toISOString().split('T')[0] // YYYY-MM-DD format
    };
    
    // Add the new guide to Firestore
    await guidesRef.doc(newGuide.id.toString()).set(newGuide);
    
    return newGuide;
  } catch (error) {
    console.error(`Error adding guide for game ${gameId} to Firebase:`, error);
    // We already have the memory result, so just return that
    return memoryResult;
  }
}

// Add a new tier list to a game
async function addTierList(gameId, tierListData) {
  // First attempt to use in-memory API to have the data regardless
  const memoryResult = await memoryApi.addTierList(gameId, tierListData);
  
  if (!useFirebase) {
    return memoryResult;
  }
  
  try {
    // Now try to save to Firebase as well
    const gameDoc = await gamesCollection.doc(gameId.toString()).get();
    
    if (!gameDoc.exists) {
      throw new Error(`Game with ID ${gameId} not found`);
    }
    
    const tierListsRef = gameDoc.ref.collection('tierLists');
    
    // Use the same ID that the memory API generated
    const newTierList = {
      id: memoryResult.id,
      title: tierListData.title,
      author: tierListData.author,
      content: tierListData.content || '',
      votes: 0
    };
    
    // Add the new tier list to Firestore
    await tierListsRef.doc(newTierList.id.toString()).set(newTierList);
    
    return newTierList;
  } catch (error) {
    console.error(`Error adding tier list for game ${gameId} to Firebase:`, error);
    // We already have the memory result, so just return that
    return memoryResult;
  }
}

// Try to initialize the database if Firebase is available
if (useFirebase) {
  // Wait for sample games to be loaded before initializing the database
  setTimeout(() => {
    if (sampleGames.length > 0) {
      console.log(`Starting database initialization with ${sampleGames.length} games...`);
      initializeDatabase().then(success => {
        if (success) {
          console.log('Firebase database is ready for use');
        } else {
          console.log('Firebase database initialization failed, will use in-memory fallbacks');
        }
      });
    } else {
      console.log('Cannot initialize database: No sample games loaded');
    }
  }, 1000); // Wait 1 second for sample games to load
}

module.exports = {
  getGames,
  getGameById,
  addGuide,
  addTierList,
  useFirebase
};