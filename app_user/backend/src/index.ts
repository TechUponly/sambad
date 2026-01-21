import 'reflect-metadata';
import express from 'express';
import cors from 'cors';
import { AppDataSource } from './db';

console.log("DEBUG: Starting server, about to initialize DataSource...");

AppDataSource.initialize()
  .then(async () => {
    console.log('Connected to PostgreSQL database: sambad');
    console.log('Entities loaded:', AppDataSource.entityMetadatas.map(m => m.name).join(', '));

    const app = express();
    app.use(cors());
    app.use(express.json());

    app.get('/', (req, res) => {
      res.send('<h1>Sambad Unified Backend</h1><p>Database: PostgreSQL</p>');
    });

    // GET endpoints
    app.get('/api/users', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const users = await userRepo.find();
        res.json(users);
      } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Failed to fetch users' });
      }
    });

    app.get('/api/contacts', async (req, res) => {
      try {
        const contactRepo = AppDataSource.getRepository('Contact');
        const contacts = await contactRepo.find();
        res.json(contacts);
      } catch (error) {
        res.status(500).json({ error: 'Failed' });
      }
    });

    app.get('/api/messages', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const messages = await messageRepo.find();
        res.json(messages);
      } catch (error) {
        res.status(500).json({ error: 'Failed' });
      }
    });

    // POST endpoints
    // POST endpoints
    app.post('/api/contacts', async (req, res) => {
      try {
        const contactRepo = AppDataSource.getRepository('Contact');
        const userRepo = AppDataSource.getRepository('User');
        
        // Handle both formats:
        // Format 1 (direct): { name, phone, userId }
        // Format 2 (Flutter): { userId, contactUserId }
        
        let contactData;
        
        if (req.body.contactUserId) {
          // Flutter format - get user details by ID
          const contactUser = await userRepo.findOne({ 
            where: { id: req.body.contactUserId } 
          });
          
          if (!contactUser) {
            return res.status(404).json({ error: 'Contact user not found' });
          }
          
          contactData = {
            name: contactUser.name || contactUser.phone,
            phone: contactUser.phone,
            userId: req.body.userId
          };
        } else {
          // Direct format
          contactData = req.body;
        }
        
        const contact = contactRepo.create(contactData);
        const saved = await contactRepo.save(contact);
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error saving contact:', error);
        res.status(500).json({ error: 'Failed to save contact' });
      }
    });
    app.post('/api/users/login', async (req, res) => {
      try {
        const userRepo = AppDataSource.getRepository('User');
        const { phone } = req.body;
        let user = await userRepo.findOne({ where: { phone } });
        if (!user) {
          user = userRepo.create({ phone, status: 'active' });
          user = await userRepo.save(user);
        }
        res.json(user);
      } catch (error) {
        console.error('Error in login:', error);
        res.status(500).json({ error: 'Login failed' });
      }
    });

    app.post('/api/messages', async (req, res) => {
      try {
        const messageRepo = AppDataSource.getRepository('Message');
        const message = messageRepo.create(req.body);
        const saved = await messageRepo.save(message);
        res.status(201).json(saved);
      } catch (error) {
        console.error('Error saving message:', error);
        res.status(500).json({ error: 'Failed to save message' });
      }
    });

    app.get('/api/health', (req, res) => {
      res.json({ status: 'healthy', database: 'connected' });
    });

    app.listen(4000, () => {
      console.log('Server on port 4000');
    });
  })
  .catch((error) => {
    console.error('Database error:', error);
    process.exit(1);
  });
