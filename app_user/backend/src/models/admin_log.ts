import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, JoinColumn } from 'typeorm';
import { AdminUser } from './admin_user';

@Entity('admin_audit_logs')
export class AdminLog {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column({ type: 'uuid', nullable: true })
  admin_id: string | null;

  @ManyToOne(() => AdminUser, { nullable: true })
  @JoinColumn({ name: 'admin_id' })
  admin_user: AdminUser;

  @Column({ type: 'varchar' })
  action: string;

  @Column({ type: 'varchar', nullable: true })
  target_type: string | null;

  @Column({ type: 'varchar', nullable: true })
  target_id: string | null;

  @CreateDateColumn()
  timestamp: Date;

  @Column({ type: 'jsonb', nullable: true })
  details: any;
}
