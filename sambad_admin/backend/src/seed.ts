import bcrypt from 'bcryptjs';
import { AppDataSource } from './db';
import { AdminUser } from './models/admin_user';

/**
 * Seeds the default super_admin if no admin users exist.
 * Uses the existing credentials: 7718811069 / Taksh@060921
 */
export async function seedDefaultAdmin() {
  try {
    const repo = AppDataSource.getRepository(AdminUser);
    const count = await repo.count();

    if (count === 0) {
      const passwordHash = await bcrypt.hash('Taksh@060921', 12);
      const admin = repo.create({
        username: '7718811069',
        email: 'admin@sambad.app',
        password_hash: passwordHash,
        role: 'super_admin',
        is_active: true,
      });
      await repo.save(admin);
      console.log('🔑 Default super_admin created: username=7718811069');
    } else {
      console.log(`✅ ${count} admin user(s) already exist — skipping seed`);
    }
  } catch (error: any) {
    console.error('⚠️  Failed to seed admin user:', error.message);
  }
}
