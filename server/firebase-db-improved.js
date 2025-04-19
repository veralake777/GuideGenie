// Improved Firebase implementation for Guide Genie API
const admin = require('firebase-admin');
require('dotenv').config();

console.log('Initializing Firebase Admin...');

// Format the private key correctly for Firebase Admin SDK
let privateKey = process.env.FIREBASE_PRIVATE_KEY || '';
if (privateKey) {
  // Replace escaped newlines with actual newlines
  privateKey = privateKey.replace(/\\n/g, '\n');
  
  // Remove any extra quotes that might be present
  privateKey = privateKey.replace(/^"(.*)"$/, '$1');
}

// Initialize Firebase Admin with proper error handling
try {
  const app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.VITE_FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: privateKey
    })
  });
  
  console.log('Firebase Admin initialized successfully!');
} catch (error) {
  console.error('Firebase Admin initialization error:', error);
  // Since we're using the unified API, we don't need to handle errors here
  // The unified API will fallback to in-memory if Firebase operations fail
}

// Get Firestore instance - this won't throw if Firebase Admin failed
const db = admin.firestore ? admin.firestore() : null;

// Import sample data for initialization
const sampleGames = require('./api-handler').getGames();

// Create collections references - these won't throw if db is null
const gamesCollection = db ? db.collection('games') : null;

// Initialize the Firebase database with sample data if it's empty
async function initializeDatabase() {
  try {
    if (!gamesCollection) {
      throw new Error('Firestore not initialized');
    }
    
    // Check if the database already has data
    const gamesSnapshot = await gamesCollection.get();
    
    if (gamesSnapshot.empty) {
      console.log('Initializing Firebase database with sample data...');
      
      // Batch writes for better performance and atomicity
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
      
      // Now add subcollections (guides and tierLists) for each game
      for (const game of sampleGames) {
        const gameRef = gamesCollection.doc(game.id.toString());
        
        // Add guides subcollection
        const guidesRef = gameRef.collection('guides');
        const guidesBatch = db.batch();
        
        for (const guide of game.guides) {
          guidesBatch.set(guidesRef.doc(guide.id.toString()), guide);
        }
        
        await guidesBatch.commit();
        
        // Add tierLists subcollection
        const tierListsRef = gameRef.collection('tierLists');
        const tierListsBatch = db.batch();
        
        for (const tierList of game.tierLists) {
          tierListsBatch.set(tierListsRef.doc(tierList.id.toString()), tierList);
        }
        
        await tierListsBatch.commit();
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
    if (!gamesCollection) {
      throw new Error('Firestore not initialized');
    }
    
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
    throw error; // Let the unified API handle the fallback
  }
}

// Get a single game by ID
async function getGameById(gameId) {
  try {
    if (!gamesCollection) {
      throw new Error('Firestore not initialized');
    }
    
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
    throw error; // Let the unified API handle the fallback
  }
}

// Add a new guide to a game
async function addGuide(gameId, guideData) {
  try {
    if (!gamesCollection) {
      throw new Error('Firestore not initialized');
    }
    
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
    throw error; // Let the unified API handle the fallback
  }
}

// Add a new tier list to a game
async function addTierList(gameId, tierListData) {
  try {
    if (!gamesCollection) {
      throw new Error('Firestore not initialized');
    }
    
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
    throw error; // Let the unified API handle the fallback
  }
}

// Try to initialize the database, but don't block server startup
if (gamesCollection) {
  initializeDatabase().then(success => {
    if (success) {
      console.log('Firebase database is ready');
    } else {
      console.log('Could not initialize Firebase database');
    }
  });
}

module.exports = {
  getGames,
  getGameById,
  addGuide,
  addTierList
};