// Minimal test server to verify Node.js/Express works
const express = require('express');
const http = require('http');

const app = express();
const server = http.createServer(app);

app.get('/', (req, res) => {
  res.send('Test server is working!');
});

const PORT = 4001;

server.listen(PORT, () => {
  console.log(`✅ Test server listening on port ${PORT}`);
  console.log(`🌐 Test: http://localhost:${PORT}/`);
});

server.on('error', (err) => {
  console.error('❌ Server error:', err);
  process.exit(1);
});
