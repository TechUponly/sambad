import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('user_feedback')
export class UserFeedback {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', nullable: true })
  userId: string;

  @Column({ nullable: true })
  userName: string;

  @Column({ nullable: true })
  userPhone: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ default: 'general' })
  category: string; // general, bug, feature, security

  @Column({ default: 1 })
  rating: number; // 1-5 star rating

  @Column({ default: 'new' })
  status: string; // new, read, resolved

  @CreateDateColumn()
  created_at: Date;
}
