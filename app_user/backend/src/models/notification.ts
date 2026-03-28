import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  body: string;

  @Column({ default: 'all' })
  audience: string; // 'all' or 'specific'

  @Column({ type: 'text', nullable: true })
  target_user_ids: string; // JSON array of user IDs when audience='specific'

  @Column({ default: 0 })
  sent_count: number;

  @Column({ default: 0 })
  failed_count: number;

  @CreateDateColumn()
  created_at: Date;
}
