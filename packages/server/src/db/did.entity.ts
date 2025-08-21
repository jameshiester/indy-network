import {
  Entity,
  PrimaryColumn,
  Column,
  UpdateDateColumn,
  CreateDateColumn,
} from 'typeorm';
import { IndyRoleType, IDid } from 'model';

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

  @Column({ type: 'simple-json' })
  attributes?: any;

  @Column({ nullable: true, type: 'timestamp' })
  transactionTime?: Date;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}
