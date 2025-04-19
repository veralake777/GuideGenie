const admin = require('firebase-admin');
require('dotenv').config();

console.log('Initializing Firebase Admin...');

// Format the private key correctly
let privateKey = process.env.FIREBASE_PRIVATE_KEY;

// Check if the private key needs additional formatting
if (privateKey) {
  // Remove any extra quotes that might be present
  privateKey = privateKey.replace(/\\n/g, '\n');
  
  // Add PEM header/footer if not present
  if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
    privateKey = '-----BEGIN PRIVATE KEY-----\n' + privateKey + '\n-----END PRIVATE KEY-----';
  }
  
  // Sometimes environment variables can have extra quotes
  privateKey = privateKey.replace(/^"(.*)"$/, '$1');
}

try {
  const app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.VITE_FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: privateKey
    })
  });
  
  console.log('Firebase Admin initialized successfully!');
  
  // Get Firestore instance
  const db = admin.firestore();
  
  // Create collections references
  const gamesCollection = db.collection('games');
  const guidesCollection = db.collection('guides');
  const tierListsCollection = db.collection('tierLists');
  
  // Export the database instance and collections
  module.exports = {
    db,
    gamesCollection,
    guidesCollection,
    tierListsCollection
  };
  
} catch (error) {
  console.error('Firebase Admin initialization error:', error);
  console.error('Using fallback in-memory storage instead');
  
  // Create mock collections for fallback
  const mockDb = {};
  const mockGamesCollection = { doc: () => ({}) };
  const mockGuidesCollection = { doc: () => ({}) };
  const mockTierListsCollection = { doc: () => ({}) };
  
  module.exports = {
    db: mockDb,
    gamesCollection: mockGamesCollection,
    guidesCollection: mockGuidesCollection,
    tierListsCollection: mockTierListsCollection
  };
}