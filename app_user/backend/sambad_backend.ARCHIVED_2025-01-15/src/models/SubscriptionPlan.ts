import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from "typeorm";

@Entity("subscription_plans")
export class SubscriptionPlan {
  @PrimaryGeneratedColumn("uuid")
  id!: string;

  @Column({ unique: true })
  code!: string; // BASIC, PRO, ENTERPRISE

  @Column()
  name!: string;

  @Column({ type: "float" })
  price!: number;

  @Column()
  currency!: string; // INR, USD

  @Column()
  billing_cycle!: string; // MONTHLY, YEARLY

  @Column({ default: true })
  active!: boolean;

  @CreateDateColumn({ type: "datetime" })
  created_at!: Date;
}
