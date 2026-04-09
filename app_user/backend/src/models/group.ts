import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('groups')
export class Group {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true, default: '' })
  description: string;

  @Column({ name: 'created_by' })
  created_by: string;

  @CreateDateColumn()
  created_at: Date;
}
