// Improved Firebase configuration with robust error handling
const admin = require('firebase-admin');
require('dotenv').config();

// Log environment variable presence (not values)
console.log('Firebase Config Check:');
console.log('- Project ID present:', !!process.env.VITE_FIREBASE_PROJECT_ID);
console.log('- Client Email present:', !!process.env.FIREBASE_CLIENT_EMAIL);
console.log('- Private Key present:', !!process.env.FIREBASE_PRIVATE_KEY);

// Test if all required Firebase variables are present
const hasAllFirebaseVars = 
  !!process.env.VITE_FIREBASE_PROJECT_ID && 
  !!process.env.FIREBASE_CLIENT_EMAIL && 
  !!process.env.FIREBASE_PRIVATE_KEY;

// Mock objects for fallback
const mockDb = {};
const mockGamesCollection = { 
  get: async () => ({ empty: true, docs: [] }),
  doc: () => ({ 
    get: async () => ({ exists: false, data: () => null }),
    collection: () => mockGamesCollection
  }) 
};

// Main export object
let firebaseExports = {
  db: mockDb,
  gamesCollection: mockGamesCollection,
  guidesCollection: mockGamesCollection,
  tierListsCollection: mockGamesCollection,
  isUsingFirebase: false
};

// Only attempt Firebase initialization if all variables are present
if (hasAllFirebaseVars) {
  try {
    // Format the private key correctly
    let privateKey = process.env.FIREBASE_PRIVATE_KEY;
    
    // Clean up the private key formatting
    if (privateKey) {
      // Replace escaped newlines with actual newlines
      privateKey = privateKey.replace(/\\n/g, '\n');
      
      // Remove any extra quotes that might be present
      privateKey = privateKey.replace(/^"(.*)"$/, '$1');
      
      // Ensure the key has proper PEM format
      if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
        console.log('Adding PEM headers to private key');
        privateKey = '-----BEGIN PRIVATE KEY-----\n' + privateKey;
      }
      
      if (!privateKey.includes('-----END PRIVATE KEY-----')) {
        console.log('Adding PEM footers to private key');
        privateKey = privateKey + '\n-----END PRIVATE KEY-----';
      }
    }
    
    // Initialize Firebase Admin
    const app = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.VITE_FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: privateKey
      })
    });
    
    console.log('Firebase Admin initialized successfully!');
    
    // Test Firestore access
    const db = admin.firestore();
    
    // Create collections references
    const gamesCollection = db.collection('games');
    const guidesCollection = db.collection('guides');
    const tierListsCollection = db.collection('tierLists');
    
    // Update exports with real Firebase objects
    firebaseExports = {
      db,
      gamesCollection,
      guidesCollection,
      tierListsCollection,
      isUsingFirebase: true
    };
    
  } catch (error) {
    console.error('Firebase Admin initialization error:', error);
    console.error('Using fallback objects for Firebase');
  }
} else {
  console.log('Missing Firebase configuration variables, using fallback objects');
}

module.exports = firebaseExports;