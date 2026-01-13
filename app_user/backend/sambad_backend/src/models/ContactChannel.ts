import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './User';

@Entity('contact_channels')
export class ContactChannel {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @Column()
  user_id!: string;

  @Column()
  channel!: string;

  @Column()
  address!: string;

  @Column({ default: false })
  verified!: boolean;

  @CreateDateColumn()
  created_at!: Date;
}
