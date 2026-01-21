import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user';

@Entity('message')
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  content: string;

  @Column()
  timestamp: string;

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
