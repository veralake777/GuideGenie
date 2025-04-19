// Unified API that combines in-memory and Firebase approaches
const memoryApi = require('./api-handler');
require('dotenv').config();

// Store API implementation
let api = memoryApi;
let isUsingFirebase = false;

// Try to initialize Firebase only if all required variables are present
const hasAllFirebaseVars = 
  !!process.env.VITE_FIREBASE_PROJECT_ID && 
  !!process.env.FIREBASE_CLIENT_EMAIL && 
  !!process.env.FIREBASE_PRIVATE_KEY;

if (hasAllFirebaseVars) {
  try {
    // We'll try to require the more robust Firebase implementation, but won't fail if it doesn't work
    const firebaseApi = require('./firebase-robust');
    api = firebaseApi;
    isUsingFirebase = firebaseApi.useFirebase;
    console.log(`Using ${isUsingFirebase ? 'Firebase' : 'in-memory fallback'} API implementation`);
  } catch (error) {
    console.error('Error initializing Firebase API:', error);
    console.log('Falling back to in-memory API implementation');
  }
} else {
  console.log('Missing Firebase configuration variables, using in-memory API implementation');
}

// API Methods with additional debugging and fallback handling

// Get all games
async function getGames() {
  try {
    console.log('Fetching all games...');
    const games = await api.getGames();
    console.log(`Successfully retrieved ${games.length} games`);
    return games;
  } catch (error) {
    console.error('Error in getGames:', error);
    console.log('Falling back to in-memory implementation');
    return await memoryApi.getGames();
  }
}

// Get a single game by ID
async function getGameById(id) {
  try {
    console.log(`Fetching game with ID: ${id}`);
    const game = await api.getGameById(id);
    
    if (!game) {
      console.log(`Game with ID ${id} not found`);
      return null;
    }
    
    console.log(`Successfully retrieved game: ${game.name}`);
    return game;
  } catch (error) {
    console.error(`Error in getGameById for ${id}:`, error);
    console.log('Falling back to in-memory implementation');
    return await memoryApi.getGameById(id);
  }
}

// Add a new guide to a game
async function addGuide(gameId, guideData) {
  try {
    console.log(`Adding guide to game ${gameId}: ${guideData.title}`);
    const newGuide = await api.addGuide(gameId, guideData);
    console.log(`Successfully added guide with ID: ${newGuide.id}`);
    return newGuide;
  } catch (error) {
    console.error(`Error in addGuide for game ${gameId}:`, error);
    console.log('Falling back to in-memory implementation');
    return await memoryApi.addGuide(gameId, guideData);
  }
}

// Add a new tier list to a game
async function addTierList(gameId, tierListData) {
  try {
    console.log(`Adding tier list to game ${gameId}: ${tierListData.title}`);
    const newTierList = await api.addTierList(gameId, tierListData);
    console.log(`Successfully added tier list with ID: ${newTierList.id}`);
    return newTierList;
  } catch (error) {
    console.error(`Error in addTierList for game ${gameId}:`, error);
    console.log('Falling back to in-memory implementation');
    return await memoryApi.addTierList(gameId, tierListData);
  }
}

// Check which implementation is being used
function getApiStatus() {
  return {
    isUsingFirebase: typeof isUsingFirebase === 'object' ? process.env.VITE_FIREBASE_PROJECT_ID : !!isUsingFirebase,
    implementation: (isUsingFirebase && typeof isUsingFirebase !== 'object') ? 'Firebase' : 'In-Memory',
    hasValidFirebaseConfig: hasAllFirebaseVars
  };
}

module.exports = {
  getGames,
  getGameById,
  addGuide,
  addTierList,
  getApiStatus
};