import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Pointer } from "../db/pointer.entity";

@Injectable()
export class PointerService{
    constructor(
        @InjectRepository(Pointer)
        private pointerRepository: Repository<Pointer>,
    ){}

    async getLatest(ledger: number): Promise<number>{
        const result = await this.pointerRepository.findOne({
            where: {
                ledger,
            }
        });
        if(!result){
            return 0;
        }
        return result.sequence;
    }

    async setLatest(ledger: number, sequence: number): Promise<Pointer>{
        const pointer = new Pointer();
        pointer.ledger = ledger;
        pointer.sequence = sequence;
        return this.pointerRepository.save(pointer);
    }
}