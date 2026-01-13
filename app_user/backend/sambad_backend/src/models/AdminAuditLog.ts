import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { AdminUser } from './AdminUser';

@Entity('admin_audit_logs')
export class AdminAuditLog {
  @PrimaryGeneratedColumn('increment')
  id!: number;

  @ManyToOne(() => AdminUser, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'admin_id' })
  admin!: AdminUser;

  @Column({ nullable: true })
  admin_id!: string;

  @Column()
  action!: string;

  @Column({ nullable: true })
  target_type!: string;

  @Column({ nullable: true })
  target_id!: string;

  @Column({ type: 'simple-json', nullable: true })
  metadata!: object;

  @CreateDateColumn()
  created_at!: Date;
}
