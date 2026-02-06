// This file re-exports the unified AppDataSource from user backend
// All admin features should use this unified DataSource for immediate data reflection

import { AppDataSource } from '../../../app_user/backend/src/db';

// Export as AdminDataSource for backward compatibility
export const AdminDataSource = AppDataSource;

// Also export as AppDataSource
export { AppDataSource };
