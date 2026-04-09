import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('group_members')
export class GroupMember {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'group_id' })
  group_id: string;

  @Column({ name: 'user_id' })
  user_id: string;

  @Column({ default: 'member' })
  role: string; // 'admin' | 'member'

  @CreateDateColumn()
  joined_at: Date;
}
