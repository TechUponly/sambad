// Test database connection
import 'reflect-metadata';
import { AdminDataSource } from './src/data-source';

async function test() {
  try {
    console.log('Testing database connection...');
    console.log('Host:', process.env.ADMIN_DB_HOST || 'localhost');
    console.log('Database:', process.env.ADMIN_DB_NAME || 'sambad_admin');
    
    await AdminDataSource.initialize();
    console.log('✅ Database connected!');
    
    const repo = AdminDataSource.getRepository(require('./src/models/admin_user').AdminUser);
    const count = await repo.count();
    console.log(`✅ Found ${count} admin users`);
    
    await AdminDataSource.destroy();
    console.log('✅ Connection closed');
    process.exit(0);
  } catch (error: any) {
    console.error('❌ Database connection failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

test();
