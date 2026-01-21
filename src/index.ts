import 'reflect-metadata';
import express from 'express';
import { AppDataSource } from './db';

// Initialize DataSource
AppDataSource.initialize()
  .then(async () => {
    console.log('✅ Connected to PostgreSQL database: sambad');
    console.log('✅ Entities loaded:', AppDataSource.entityMetadatas.map(m => m.name).join(', '));

    const app = express();
    app.use(express.json());

    app.get('/', (req, res) => {
      res.send(`
        <h1>Sambad Unified Backend is running!</h1>
        <p>✅ Database: PostgreSQL (sambad)</p>
        <p>✅ Entities: ${AppDataSource.entityMetadatas.map(m => m.name).join(', ')}</p>
        <hr>
        <p><a href="/api/users">View Users</a> | <a href="/api/contacts">View Contacts</a> | <a href="/api/messages">View Messages</a></p>
      `);
    });

    // Get all users
    app.get('/api/users', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const users = await userRepo.find();
        res.json(users);
      } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
      }
    });

    // Get all contacts
    app.get('/api/contacts', async (req, res) => {
      try {
        const contactRepo = AppDataSource.getRepository('Contact');
        const contacts = await contactRepo.find({
          relations: ['user', 'contact_user'],
          order: { created_at: 'DESC' },
        });
        res.json(contacts);
      } catch (error) {
        console.error('Error fetching contacts:', error);
        res.status(500).json({ error: 'Failed to fetch contacts' });
      }
    });

    // Get all messages
    app.get('/api/messages', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const messages = await messageRepo.find({
          relations: ['from_user', 'to_user', 'group'],
          order: { created_at: 'DESC' },
        });
        res.json(messages);
      } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: 'Failed to fetch messages' });
      }
    });

    // Health check endpoint
    app.get('/api/health', (req, res) => {
      res.json({
        status: 'healthy',
        database: 'connected',
        type: AppDataSource.options.type,
        entities: AppDataSource.entityMetadatas.map(m => m.name)
      });
    });

    const PORT = process.env.PORT || 4000;
    app.listen(PORT, () => {
      console.log(`✅ User backend listening on port ${PORT`);
      console.log(`✅ Health check: http://localhost:${PORT}/api/health`);
    });

  })
  .catch((error) => {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  });
