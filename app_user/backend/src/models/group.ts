import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, JoinColumn } from 'typeorm';
import { User } from './user';

@Entity('groups')
export class Group {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @ManyToOne(() => User, user => user.id)
  @JoinColumn({ name: 'created_by' })
  created_by: User;

  @CreateDateColumn()
  created_at: Date;
}
