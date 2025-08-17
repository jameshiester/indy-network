import { Entity, PrimaryColumn, Column, UpdateDateColumn, CreateDateColumn } from 'typeorm';
import { IndyRoleType, IndyTransactionType } from 'model';

@Entity()
export class Transaction {
  @PrimaryColumn('int')
  id!: number;

  @PrimaryColumn('int')
  ledger!:number;

  @Column({nullable: true})
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
  value?: any;

  @Column({ nullable: true })
  source?: string;

  @Column({ nullable: true })
  destination?: string;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt!: Date;
}