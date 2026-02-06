// Simplified server to test if basic Express works
import 'reflect-metadata';
import express from 'express';

const app = express();
app.use(express.json());

app.get('/', (_req, res) => {
  res.send('Sambad Admin Backend is running!');
});

app.post('/login', async (req, res) => {
  res.json({ message: 'Login endpoint reached', body: req.body });
});

const PORT = 5050;
app.listen(PORT, () => {
  console.log(`Admin backend listening on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/`);
});
