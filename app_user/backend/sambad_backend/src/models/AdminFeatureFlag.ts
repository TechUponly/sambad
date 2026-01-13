import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from "typeorm";

@Entity("admin_feature_flags")
export class AdminFeatureFlag {
  @PrimaryGeneratedColumn("uuid")
  id!: string;

  @Column({ unique: true })
  key!: string; // e.g. ENABLE_PAYMENTS, ENABLE_CALL_RECORDING

  @Column({ default: false })
  enabled!: boolean;

  @Column({ nullable: true })
  description!: string;

  @Column()
  updated_by_admin_id!: string;

  @CreateDateColumn({ type: "datetime" })
  updated_at!: Date;
}
