"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppDataSource = void 0;
exports.initDB = initDB;
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const User_1 = require("./models/User");
const UserConsent_1 = require("./models/UserConsent");
const ContactChannel_1 = require("./models/ContactChannel");
const UserEvent_1 = require("./models/UserEvent");
const AdminUser_1 = require("./models/AdminUser");
const AdminAuditLog_1 = require("./models/AdminAuditLog");
const AdminFeatureFlag_1 = require("./models/AdminFeatureFlag");
const SubscriptionPlan_1 = require("./models/SubscriptionPlan");
const UserSubscription_1 = require("./models/UserSubscription");
exports.AppDataSource = new typeorm_1.DataSource({
    type: "sqlite",
    database: "sambad.db",
    synchronize: true,
    logging: false,
    entities: [
        User_1.User,
        UserConsent_1.UserConsent,
        ContactChannel_1.ContactChannel,
        UserEvent_1.UserEvent,
        AdminUser_1.AdminUser,
        AdminAuditLog_1.AdminAuditLog,
        AdminFeatureFlag_1.AdminFeatureFlag,
        SubscriptionPlan_1.SubscriptionPlan,
        UserSubscription_1.UserSubscription,
    ],
});
async function initDB() {
    if (!exports.AppDataSource.isInitialized) {
        await exports.AppDataSource.initialize();
    }
    return exports.AppDataSource;
}
