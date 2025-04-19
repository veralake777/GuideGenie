// Simplified Firebase initialization with improved key handling
const admin = require('firebase-admin');
require('dotenv').config();
const { formatFirebasePrivateKey } = require('./firebase-key-util');

// Check for required environment variables
const projectId = process.env.VITE_FIREBASE_PROJECT_ID;
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
const privateKey = formatFirebasePrivateKey();

// Export objects for use in other modules
let firebaseApp = null;
let firestoreDb = null;
let initialized = false;

try {
  if (!projectId || !clientEmail || !privateKey) {
    throw new Error('Missing required Firebase configuration');
  }
  
  // Initialize the Firebase Admin app
  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: projectId,
      clientEmail: clientEmail,
      privateKey: privateKey
    })
  });
  
  // Initialize Firestore
  firestoreDb = admin.firestore();
  
  console.log('Firebase Admin SDK initialized successfully!');
  initialized = true;
  
} catch (error) {
  console.error('Error initializing Firebase Admin:', error);
  console.log('Firebase integration will not be available');
}

module.exports = {
  admin,
  firebaseApp,
  db: firestoreDb,
  initialized
};