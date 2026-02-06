# Contacts Sync Implementation - Next Steps

## ✅ Completed
1. Added packages to pubspec.yaml:
   - contacts_service: ^0.6.3
   - permission_handler: ^11.0.1
2. Created contacts_sync_service.dart in Flutter

## 🔧 To Complete

### 1. Backend API Endpoint
Create: `app_user/backend/src/routes/contacts-sync.ts`
```typescript
import { Router } from 'express';
import { AppDataSource } from '../data-source';
import { Contact } from '../models/Contact';
import { User } from '../models/User';

const router = Router();

router.post('/sync-contacts', async (req, res) => {
  try {
    const { contacts } = req.body;
    const userId = (req as any).user?.id;
    
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });
    
    const contactRepo = AppDataSource.getRepository(Contact);
    const userRepo = AppDataSource.getRepository(User);
    const sambadUsers = [];
    
    for (const contact of contacts) {
      const existingUser = await userRepo.findOne({ where: { username: contact.phone } });
      
      if (existingUser && existingUser.id !== userId) {
        const existingContact = await contactRepo.findOne({
          where: { user_id: userId, contact_user_id: existingUser.id }
        });
        
        if (!existingContact) {
          const newContact = contactRepo.create({
            user_id: userId,
            contact_user_id: existingUser.id,
          });
          await contactRepo.save(newContact);
        }
        
        sambadUsers.push({ id: existingUser.id, name: contact.name, phone: contact.phone });
      }
    }
    
    res.json({ success: true, totalContacts: contacts.length, sambadUsers });
  } catch (error) {
    res.status(500).json({ error: 'Failed to sync' });
  }
});

export default router;
```

### 2. Register Route in Backend
In `app_user/backend/src/index.ts`, add:
```typescript
import contactsSyncRouter from './routes/contacts-sync';
app.use('/sync-contacts', contactsSyncRouter);
```

### 3. Update Login Screen
Add contacts permission request after successful login in `lib/screens/login_screen.dart`

### 4. Android Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

### 5. iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSContactsUsageDescription</key>
<string>Sambad needs access to your contacts to help you connect with friends.</string>
```

## Summary
- Frontend: ✅ Service created
- Backend: ⏳ Need to create endpoint
- Permissions: ⏳ Need to add to manifests
- Login: ⏳ Need to trigger sync after login

Total remaining: 10 minutes of work
