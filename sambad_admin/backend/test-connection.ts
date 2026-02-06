/**
 * Quick test to verify database connection works
 */
import 'reflect-metadata';
import { AdminDataSource } from './src/data-source';

// Set env vars inline for testing
process.env.ADMIN_DB_HOST = 'localhost';
process.env.ADMIN_DB_PORT = '5432';
process.env.ADMIN_DB_USER = 'postgres';
process.env.ADMIN_DB_PASSWORD = 'changeme';
process.env.ADMIN_DB_NAME = 'sambad_admin';

async function test() {
  try {
    console.log('Testing database connection...');
    await AdminDataSource.initialize();
    console.log('✅ Database connected successfully!');
    
    const repo = AdminDataSource.getRepository(require('./src/models/admin_user').AdminUser);
    const admin = await repo.findOne({ where: { username: 'testadmin' } });
    
    if (admin) {
      console.log('✅ Test admin found:', admin.username, admin.role);
    } else {
      console.log('⚠️  Test admin not found');
    }
    
    await AdminDataSource.destroy();
    console.log('✅ Test complete');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

test();
