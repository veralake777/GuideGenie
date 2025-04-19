// Utility to help format Firebase private keys properly
require('dotenv').config();

/**
 * Format a Firebase private key string to ensure it's in the correct PEM format
 * This handles various issues with how private keys are stored in environment variables
 */
function formatFirebasePrivateKey() {
  // Get the raw key from the environment
  let rawKey = process.env.FIREBASE_PRIVATE_KEY || '';
  
  console.log('Original key length:', rawKey.length);
  
  if (!rawKey || rawKey.length < 10) {
    console.log('FIREBASE_PRIVATE_KEY is missing or too short');
    return null;
  }
  
  try {
    // Step 1: Remove any extra quotes that might be present
    rawKey = rawKey.replace(/^["']|["']$/g, '');
    
    // Step 2: Handle case where \n is literal text rather than newline
    rawKey = rawKey.replace(/\\n/g, '\n');
    
    // Step 3: Check if we have a properly formatted PEM key
    if (!rawKey.includes('-----BEGIN PRIVATE KEY-----')) {
      console.log('Adding PEM header to key');
      rawKey = '-----BEGIN PRIVATE KEY-----\n' + rawKey;
    }
    
    if (!rawKey.includes('-----END PRIVATE KEY-----')) {
      console.log('Adding PEM footer to key');
      rawKey = rawKey + '\n-----END PRIVATE KEY-----';
    }
    
    // Log some info about the formatted key (but not the key itself)
    console.log('Formatted key length:', rawKey.length);
    console.log('Key contains BEGIN marker:', rawKey.includes('-----BEGIN PRIVATE KEY-----'));
    console.log('Key contains END marker:', rawKey.includes('-----END PRIVATE KEY-----'));
    console.log('Number of newlines:', (rawKey.match(/\n/g) || []).length);
    
    return rawKey;
  } catch (error) {
    console.error('Error formatting private key:', error);
    return null;
  }
}

module.exports = {
  formatFirebasePrivateKey
};