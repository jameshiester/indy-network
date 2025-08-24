import { IDid, IndyRoleType } from 'model';
import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity()
export class Did implements IDid {
  @PrimaryColumn()
  id!: string;

  @Column({ nullable: true })
  from?: string;

  @Column({ nullable: true })
  role?: IndyRoleType;

  @Column()
  verkey?: string;

  @Column()
  alias?: string;

  @Column()
  transactionId?: number;

  @Column({ nullable: true })
  roleName?: string;

  @Column({ type: 'simple-json', nullable: true })
  attributes?: Record<string, unknown>;

  @Column({ nullable: true, type: 'timestamp' })
  transactionTime?: Date;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}
