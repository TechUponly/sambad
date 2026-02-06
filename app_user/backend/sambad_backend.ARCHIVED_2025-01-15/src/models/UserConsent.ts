import { Entity, PrimaryColumn, Column, UpdateDateColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from './User';

@Entity('user_consents')
export class UserConsent {
  @PrimaryColumn('uuid')
  user_id!: string;

  @OneToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @Column({ default: false })
  analytics_consent!: boolean;

  @Column({ default: false })
  marketing_consent!: boolean;

  @Column({ nullable: true })
  terms_version!: string;

  @UpdateDateColumn()
  updated_at!: Date;
}
