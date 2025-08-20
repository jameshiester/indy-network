import { INode } from 'model';
import { Entity, PrimaryColumn, Column } from 'typeorm';

@Entity()
export class Node implements INode {
  @PrimaryColumn()
  name!: string;

  @Column()
  active!: boolean;

  @Column('simple-json', { nullable: true })
  value?: unknown;

  @Column({ nullable: true })
  indy_version?: string;

  @Column({ nullable: true })
  did?: string;

  @Column({ nullable: true })
  verkey?: string;

  @Column('bigint', { nullable: true })
  uptime_seconds?: number;
}
