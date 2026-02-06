/**
 * Script to create a test admin user for testing authentication
 * Run with: ts-node scripts/create-test-admin.ts
 */
import 'reflect-metadata';
import bcrypt from 'bcryptjs';
import { AdminDataSource } from '../src/data-source';
import { AdminUser } from '../src/models/admin_user';

async function createTestAdmin() {
  try {
    await AdminDataSource.initialize();
    console.log('✅ Database connected');

    const repo = AdminDataSource.getRepository(AdminUser);

    // Check if admin already exists
    const existing = await repo.findOne({ where: { username: 'testadmin' } });
    if (existing) {
      console.log('⚠️  Admin user "testadmin" already exists');
      console.log('   ID:', existing.id);
      console.log('   Email:', existing.email);
      console.log('   Role:', existing.role);
      await AdminDataSource.destroy();
      return;
    }

    // Create test admin
    const password = 'TestAdmin123!';
    const passwordHash = await bcrypt.hash(password, 10);

    const admin = repo.create({
      username: 'testadmin',
      email: 'testadmin@sambad.com',
      password_hash: passwordHash,
      role: 'superadmin',
    });

    const saved = await repo.save(admin);
    console.log('✅ Test admin created successfully!');
    console.log('   Username: testadmin');
    console.log('   Password: TestAdmin123!');
    console.log('   Email:', saved.email);
    console.log('   Role:', saved.role);
    console.log('   ID:', saved.id);

    await AdminDataSource.destroy();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error creating admin:', error);
    process.exit(1);
  }
}

createTestAdmin();
