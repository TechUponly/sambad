// Minimal test to see if server can start
import 'reflect-metadata';
import express from 'express';

const app = express();
app.get('/', (_req, res) => {
  res.send('Test server works!');
});

const PORT = 5050;
app.listen(PORT, () => {
  console.log(`Test server listening on port ${PORT}`);
});
