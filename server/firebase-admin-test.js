// Test script for Firebase Admin initialization
const admin = require('firebase-admin');
require('dotenv').config();

console.log('Testing Firebase Admin initialization...');

// Just log the keys for debugging (not their values)
console.log('Environment variables check:');
console.log('VITE_FIREBASE_PROJECT_ID exists:', !!process.env.VITE_FIREBASE_PROJECT_ID);
console.log('FIREBASE_CLIENT_EMAIL exists:', !!process.env.FIREBASE_CLIENT_EMAIL);
console.log('FIREBASE_PRIVATE_KEY exists:', !!process.env.FIREBASE_PRIVATE_KEY);
console.log('FIREBASE_PRIVATE_KEY length:', process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.length : 0);

try {
  // Initialize with a more direct approach
  const app = admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.VITE_FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      // The specific formatting issue might be here:
      privateKey: process.env.FIREBASE_PRIVATE_KEY
    })
  });
  
  console.log('Firebase Admin initialized successfully!');
  
  // Try to access Firestore to validate connection
  const db = admin.firestore();
  console.log('Firestore accessed successfully!');
  
} catch (error) {
  console.error('Firebase Admin initialization error:', error);
  
  // More detailed error information
  if (error.code) {
    console.error('Error code:', error.code);
  }
  if (error.message) {
    console.error('Error message:', error.message);
  }
}