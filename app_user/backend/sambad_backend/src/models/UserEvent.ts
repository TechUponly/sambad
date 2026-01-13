import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './User';

@Entity('user_events')
export class UserEvent {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @Column()
  user_id!: string;

  @Column()
  event_type!: string;

  @Column({ type: 'simple-json', nullable: true })
  metadata!: object;

  @CreateDateColumn()
  created_at!: Date;
}
