import { IndyRoleType, IndyTransactionType, ITransaction } from 'model';
import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity()
export class Transaction implements ITransaction {
  @PrimaryColumn('int')
  id!: number;

  @PrimaryColumn('int')
  ledger!: number;

  @Column({ nullable: true })
  transactionType!: IndyTransactionType;

  @Column({ nullable: true })
  transactionTypeName?: string;

  @Column({ nullable: true })
  role?: IndyRoleType;

  @Column({ nullable: true })
  roleName?: string;

  @Column({ nullable: true })
  transactionId?: string;

  @Column('simple-json')
  value?: unknown;

  @Column({ nullable: true })
  from?: string;

  @Column({ nullable: true })
  destination?: string;

  @Column({ nullable: true })
  transactionTime?: Date;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}
