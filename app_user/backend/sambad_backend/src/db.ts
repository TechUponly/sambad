import "reflect-metadata";
import { DataSource } from "typeorm";

import { User } from "./models/User";
import { UserConsent } from "./models/UserConsent";
import { ContactChannel } from "./models/ContactChannel";
import { UserEvent } from "./models/UserEvent";

import { AdminUser } from "./models/AdminUser";
import { AdminAuditLog } from "./models/AdminAuditLog";
import { AdminFeatureFlag } from "./models/AdminFeatureFlag";

import { SubscriptionPlan } from "./models/SubscriptionPlan";
import { UserSubscription } from "./models/UserSubscription";

export const AppDataSource = new DataSource({
  type: "sqlite",
  database: "sambad.db",
  synchronize: true,
  logging: false,
  entities: [
    User,
    UserConsent,
    ContactChannel,
    UserEvent,
    AdminUser,
    AdminAuditLog,
    AdminFeatureFlag,
    SubscriptionPlan,
    UserSubscription,
  ],
});

export async function initDB() {
  if (!AppDataSource.isInitialized) {
    await AppDataSource.initialize();
  }
  return AppDataSource;
}
