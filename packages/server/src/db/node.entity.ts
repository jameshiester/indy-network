import { INode } from 'model';
import {
  Entity,
  PrimaryColumn,
  Column,
  UpdateDateColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity()
export class Node implements INode {
  @PrimaryColumn()
  name!: string;

  @Column()
  active!: boolean;

  @Column('simple-json', { nullable: true })
  value?: unknown;

  @Column({ nullable: true })
  indyVersion?: string;

  @Column({ nullable: true })
  did?: string;

  @Column({ nullable: true })
  verkey?: string;

  @Column('bigint', { nullable: true })
  uptimeSeconds?: number;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}
