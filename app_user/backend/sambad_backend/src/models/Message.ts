import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { User } from './User';

@Entity()
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @ManyToOne(() => User)
  from!: User;

  @ManyToOne(() => User)
  to!: User;

  @Column()
  content!: string;

  @Column()
  timestamp!: string;
}
