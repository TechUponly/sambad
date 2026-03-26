import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { User } from './user';

@Entity('message')
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  content: string;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ default: 'sent' })
  status: string; // 'sent' | 'delivered' | 'read'

  @Column({ type: 'timestamp', nullable: true })
  delivered_at: Date | null;

  @Column({ type: 'timestamp', nullable: true })
  read_at: Date | null;

  @Column({ type: 'uuid', nullable: true })
  fromId: string | null;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'fromId' })
  from_user: User;

  @Column({ type: 'uuid', nullable: true })
  toId: string | null;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'toId' })
  to_user: User;
}
