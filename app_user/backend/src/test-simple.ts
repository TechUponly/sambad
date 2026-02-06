// Simple test to isolate the issue
console.log('TEST 1: Script starts');

import 'reflect-metadata';
console.log('TEST 2: reflect-metadata loaded');

const express = require('express');
console.log('TEST 3: express loaded');

import { createServer } from 'http';
console.log('TEST 4: http loaded');

const app = express();
const server = createServer(app);
console.log('TEST 5: app and server created');

const PORT = 4000;
server.listen(PORT, () => {
  console.log(`✅ TEST SERVER listening on port ${PORT}`);
  process.exit(0);
});

setTimeout(() => {
  console.log('TEST: Timeout - server did not start');
  process.exit(1);
}, 5000);
