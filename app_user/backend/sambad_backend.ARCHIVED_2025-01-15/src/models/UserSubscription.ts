import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from "typeorm";

@Entity("user_subscriptions")
export class UserSubscription {
  @PrimaryGeneratedColumn("uuid")
  id!: string;

  @Column()
  user_id!: string;

  @Column()
  subscription_plan_id!: string;

  @Column()
  status!: string; // ACTIVE, PAUSED, CANCELLED, EXPIRED

  @Column({ type: "datetime", nullable: true })
  start_date!: Date;

  @Column({ type: "datetime", nullable: true })
  end_date!: Date;

  @Column({ nullable: true })
  activated_by_admin_id!: string;

  @CreateDateColumn({ type: "datetime" })
  created_at!: Date;
}
