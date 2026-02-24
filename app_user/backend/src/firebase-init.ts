import admin from 'firebase-admin';
import * as path from 'path';

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, '../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountPath)
});

console.log('✅ Firebase Admin initialized');

export default admin;
