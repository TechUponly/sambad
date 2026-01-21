import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  phone: string;

  @Column({ unique: true, nullable: true })
  email: string;

  @Column({ nullable: true })
  name: string;

  @Column({ default: 'active' })
  status: string;

  @CreateDateColumn()
  created_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  last_active_at: Date | null;
}
