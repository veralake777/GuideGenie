const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize Firebase Admin with environment variables
const firebaseApp = initializeApp({
  credential: cert({
    projectId: process.env.VITE_FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || 'mock@firebase.com',
    // Private key needs to be properly formatted when read from environment
    privateKey: process.env.FIREBASE_PRIVATE_KEY ? 
      process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : 
      'fake-key'
  }),
  // Additional configuration if needed:
  // databaseURL: `https://${process.env.VITE_FIREBASE_PROJECT_ID}.firebaseio.com`
});

// Get Firestore instance
const db = getFirestore();

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