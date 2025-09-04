import { INodeHistory } from 'model';
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity()
export class NodeHistory implements INodeHistory {
  @PrimaryGeneratedColumn()
  id?: number;

  @Column()
  name?: string;

  @Column({ type: 'timestamp' })
  timestamp?: Date;

  @Column({ nullable: true })
  indyVersion?: string;

  @Column('decimal', { nullable: true })
  readThroughput?: number;

  @Column('decimal', { nullable: true })
  writeThroughput?: number;

  @Column('int', { nullable: true })
  reachableNodesCount?: number;

  @Column('int', { nullable: true })
  unreachableNodesCount?: number;

  @Column()
  active?: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}
