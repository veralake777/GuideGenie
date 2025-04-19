// Firebase implementation for Guide Genie API
const firebaseConfig = require('./firebase-config-fixed');
const { db, gamesCollection, guidesCollection, tierListsCollection } = firebaseConfig;

// Import sample data for initialization
const sampleData = require('./api-handler').getGames();

// Initialize the Firebase database with sample data if it's empty
async function initializeDatabase(sampleData) {
  try {
    // Check if the database already has data
    const gamesSnapshot = await gamesCollection.get();
    
    if (gamesSnapshot.empty) {
      console.log('Initializing Firebase database with sample data...');
      
      // Add each game to the games collection
      for (const game of sampleData) {
        const gameRef = gamesCollection.doc(game.id.toString());
        
        // Remove nested collections before saving
        const { guides, tierLists, ...gameData } = game;
        await gameRef.set(gameData);
        
        // Add guides subcollection
        const guidesRef = gameRef.collection('guides');
        for (const guide of guides) {
          await guidesRef.doc(guide.id.toString()).set(guide);
        }
        
        // Add tierLists subcollection
        const tierListsRef = gameRef.collection('tierLists');
        for (const tierList of tierLists) {
          await tierListsRef.doc(tierList.id.toString()).set(tierList);
        }
      }
      
      console.log('Database initialized successfully!');
    } else {
      console.log('Database already contains data, skipping initialization.');
    }
    
    return true;
  } catch (error) {
    console.error('Error initializing database:', error);
    return false;
  }
}

// Get all games
async function getGames() {
  try {
    const gamesSnapshot = await gamesCollection.get();
    const games = [];
    
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
    // Fall back to memory API
    return sampleData;
  }
}

// Get a single game by ID
async function getGameById(gameId) {
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
    // Fall back to memory API
    return sampleData.find(game => game.id === parseInt(gameId));
  }
}

// Add a new guide to a game
async function addGuide(gameId, guideData) {
  try {
    const gameDoc = await gamesCollection.doc(gameId.toString()).get();
    
    if (!gameDoc.exists) {
      throw new Error(`Game with ID ${gameId} not found`);
    }
    
    const guidesRef = gameDoc.ref.collection('guides');
    
    // Get the next guide ID
    const guidesSnapshot = await guidesRef.get();
    const maxGuideId = guidesSnapshot.empty ? 0 : Math.max(
      ...guidesSnapshot.docs.map(doc => parseInt(doc.id))
    );
    
    const newGuide = {
      id: maxGuideId + 1,
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
    // Fall back to memory API implementation
    const memoryApi = require('./api-handler');
    return memoryApi.addGuide(gameId, guideData);
  }
}

// Add a new tier list to a game
async function addTierList(gameId, tierListData) {
  try {
    const gameDoc = await gamesCollection.doc(gameId.toString()).get();
    
    if (!gameDoc.exists) {
      throw new Error(`Game with ID ${gameId} not found`);
    }
    
    const tierListsRef = gameDoc.ref.collection('tierLists');
    
    // Get the next tier list ID
    const tierListsSnapshot = await tierListsRef.get();
    const maxTierListId = tierListsSnapshot.empty ? 0 : Math.max(
      ...tierListsSnapshot.docs.map(doc => parseInt(doc.id))
    );
    
    const newTierList = {
      id: maxTierListId + 1,
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
    // Fall back to memory API implementation
    const memoryApi = require('./api-handler');
    return memoryApi.addTierList(gameId, tierListData);
  }
}

// Initialize the database
initializeDatabase(sampleData);

module.exports = {
  getGames,
  getGameById,
  addGuide,
  addTierList
};