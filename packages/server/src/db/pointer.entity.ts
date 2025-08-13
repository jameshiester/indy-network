import { Entity, PrimaryColumn, Column } from 'typeorm';

@Entity()
export class Pointer {
  @PrimaryColumn()
  ledger!: number;

  @Column()
  sequence!: number;

  
}
