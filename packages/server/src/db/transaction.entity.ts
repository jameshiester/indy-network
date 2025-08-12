import { Entity, PrimaryColumn, Column } from 'typeorm';

@Entity()
export class Transaction {
  @PrimaryColumn('int')
  id!: number;

  @PrimaryColumn('int')
  ledger!:number;

  @Column({nullable: true})
  transactionType!: string;
}