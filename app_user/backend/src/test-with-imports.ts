// Test with all imports from index.ts
console.log('TEST: Starting with imports');

import 'reflect-metadata';
console.log('TEST: reflect-metadata loaded');

import express, { Request, Response } from 'express';
console.log('TEST: express loaded');

import cors from 'cors';
console.log('TEST: cors loaded');

import dotenv from 'dotenv';
console.log('TEST: dotenv loaded');

import bcrypt from 'bcryptjs';
console.log('TEST: bcryptjs loaded');

import { createServer } from 'http';
console.log('TEST: http loaded');

// Try loading the problematic imports
try {
  console.log('TEST: Loading AppDataSource...');
  import('./data-source').then(({ AppDataSource }) => {
    console.log('TEST: AppDataSource loaded');
  }).catch(e => console.error('ERROR loading data-source:', e));
} catch (e) {
  console.error('ERROR:', e);
}

try {
  console.log('TEST: Loading models...');
  import('./models/user').then(() => console.log('TEST: User model loaded'));
  import('./models/contact').then(() => console.log('TEST: Contact model loaded'));
  import('./models/message').then(() => console.log('TEST: Message model loaded'));
} catch (e) {
  console.error('ERROR:', e);
}

try {
  console.log('TEST: Loading middleware...');
  import('./middleware/auth').then(() => console.log('TEST: Auth middleware loaded'));
} catch (e) {
  console.error('ERROR:', e);
}

try {
  console.log('TEST: Loading websocket...');
  import('./websocket').then(() => console.log('TEST: WebSocket loaded'));
} catch (e) {
  console.error('ERROR:', e);
}

const app = express();
const server = createServer(app);
app.use(cors());
app.use(express.json());

app.get('/', (_req: express.Request, res: express.Response) => {
  res.send('Test server with imports');
});

const PORT = 4001;
server.listen(PORT, () => {
  console.log(`✅ TEST SERVER WITH IMPORTS listening on port ${PORT}`);
});
