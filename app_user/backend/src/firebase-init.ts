import admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Firebase Admin — graceful fallback if no service account
const serviceAccountPath = path.join(__dirname, '../firebase-service-account.json');

if (fs.existsSync(serviceAccountPath)) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath)
  });
  console.log('✅ Firebase Admin initialized');
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault()
  });
  console.log('✅ Firebase Admin initialized (via GOOGLE_APPLICATION_CREDENTIALS)');
} else {
  // Dev mode — initialize without credentials (auth middleware will skip verification)
  try {
    admin.initializeApp();
    console.log('⚠️  Firebase Admin initialized without credentials (dev mode)');
  } catch (e) {
    console.warn('⚠️  Firebase Admin not initialized — auth will not work');
  }
}

export default admin;
