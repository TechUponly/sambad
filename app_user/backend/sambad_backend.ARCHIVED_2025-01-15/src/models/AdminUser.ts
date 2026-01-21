import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('admin_users')
export class AdminUser {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  email!: string;

  @Column()
  password_hash!: string;

  @Column()
  role!: string; // super_admin | moderator | support | analyst

  @CreateDateColumn()
  created_at!: Date;

  @Column({ type: 'datetime', nullable: true })
  last_login_at!: Date;
}
