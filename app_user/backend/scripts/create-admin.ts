import 'reflect-metadata';
import bcrypt from 'bcryptjs';
import { AppDataSource } from '../src/data-source';
import { AdminUser } from '../src/models/admin_user';

async function createAdmin() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connected');

    const adminRepo = AppDataSource.getRepository(AdminUser);

    const username = process.argv[2] || 'admin';
    const password = process.argv[3] || 'admin123';
    const email = process.argv[4] || 'admin@sambad.com';
    const role = process.argv[5] || 'superadmin';

    // Check if admin already exists
    const existing = await adminRepo.findOne({ where: { username } });
    if (existing) {
      console.log(`⚠️  Admin user '${username}' already exists`);
      await AppDataSource.destroy();
      process.exit(0);
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Create admin
    const admin = adminRepo.create({
      username,
      email,
      password_hash,
      role,
    });

    await adminRepo.save(admin);
    console.log('✅ Admin user created successfully!');
    console.log(`   Username: ${username}`);
    console.log(`   Password: ${password}`);
    console.log(`   Email: ${email}`);
    console.log(`   Role: ${role}`);

    await AppDataSource.destroy();
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createAdmin();
