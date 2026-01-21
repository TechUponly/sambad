"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserSubscription = void 0;
const typeorm_1 = require("typeorm");
let UserSubscription = class UserSubscription {
};
exports.UserSubscription = UserSubscription;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)("uuid"),
    __metadata("design:type", String)
], UserSubscription.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], UserSubscription.prototype, "user_id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], UserSubscription.prototype, "subscription_plan_id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], UserSubscription.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: "datetime", nullable: true }),
    __metadata("design:type", Date)
], UserSubscription.prototype, "start_date", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: "datetime", nullable: true }),
    __metadata("design:type", Date)
], UserSubscription.prototype, "end_date", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], UserSubscription.prototype, "activated_by_admin_id", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ type: "datetime" }),
    __metadata("design:type", Date)
], UserSubscription.prototype, "created_at", void 0);
exports.UserSubscription = UserSubscription = __decorate([
    (0, typeorm_1.Entity)("user_subscriptions")
], UserSubscription);
