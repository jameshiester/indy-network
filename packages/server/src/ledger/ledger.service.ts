import { GetTransactionResponse, IndyVdrPool, GetTransactionRequest, PoolCreate, GetValidatorInfoAction, GetValidatorInfoResponse, indyVdr } from '@hyperledger/indy-vdr-nodejs';
import { Injectable, Logger, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Key, KeyAlgorithm, KeyMethod } from "@openwallet-foundation/askar-nodejs";
import { PointerService } from '../pointer/pointer.service.js';
import { readFile } from 'fs/promises';
import nacl from 'tweetnacl';

const tmpKey = 'password';

@Injectable()
export class LedgerService {
  private readonly logger = new Logger(LedgerService.name);
  private readonly pool: IndyVdrPool;

  constructor(private readonly pointerService: PointerService) {
    this.pool = new PoolCreate({ parameters: { transactions_path: process.env.GENESIS_TXN_PATH } })
  }

  getStatus() {
    return { status: 'ledger-ok' };
  }

  async getGenesisTransactionsText(): Promise<string> {
    const genesisFilePath = process.env.GENESIS_TXN_PATH;
    if (!genesisFilePath) {
      this.logger.error('Environment variable GENESIS_TXN_PATH is not set.');
      throw new InternalServerErrorException('GENESIS_TXN_PATH is not set');
    }
    try {
      const fileContent = await readFile(genesisFilePath, { encoding: 'utf-8' });
      return fileContent;
    } catch (error: any) {
      if (error?.code === 'ENOENT') {
        this.logger.error(`Genesis file not found at path: ${genesisFilePath}`);
        throw new NotFoundException('Genesis transactions file not found');
      }
      this.logger.error(`Failed to read genesis file: ${error?.message ?? error}`);
      throw new InternalServerErrorException('Failed to read genesis transactions file');
    }
  }

  async syncLedger(ledger: number) {
    let latest = await this.pointerService.getLatest(ledger);
    let complete = false;
    this.logger.debug(`Syncing ledger ${ledger} from ${latest}`);
    while (!complete) {
      try {
        const request = new GetTransactionRequest({ ledgerType: ledger, seqNo: latest + 1 })
        const response: GetTransactionResponse = await this.pool.submitRequest(request)

        if (response.result.seqNo === undefined) {
          this.logger.debug(`Syncing ledger ${ledger} complete. Last synced txn: ${latest}`)
          complete = true;
        } else {
          await this.pointerService.setLatest(ledger, response.result.seqNo);
          latest = response.result.seqNo;
          this.logger.debug(`Txn ${response.result.seqNo} synced from ledger ${ledger}`)
        }

      } catch (error) {
        this.logger.error(error);
        complete = true;
      }
    }
  }

  async getValidatorInfo() {
      this.logger.debug(`Syncing validator info`);
      try {
        const action = new GetValidatorInfoAction({submitterDid: undefined})
        const response: GetValidatorInfoResponse = await this.pool.submitRequest(action)
        console.log("success")
      }catch (error){
        console.log("error")
        this.logger.error(error)
      }
    
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'ascii', 'ascii', true);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'ascii', 'ascii', false);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'utf8', 'utf8', true);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'utf8', 'utf8', false);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'utf8', 'ascii', true);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'utf8', 'ascii', false);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'ascii', 'utf8', true);
      await this.submitRequest(new GetValidatorInfoAction({ submitterDid: process.env.VALIDATOR_DID }), 'ascii', 'utf8', false);
  }

  async submitRequest(request: GetValidatorInfoAction, keyEncoding: BufferEncoding, messageEncoding: BufferEncoding,useNacl: boolean) {
      this.logger.debug(`Syncing validator info`);
      let signature: Uint8Array;
      try {
        if (useNacl){
          const naclKey = nacl.sign.keyPair.fromSeed(Buffer.from(process.env.VALIDATOR_SEED,keyEncoding));
          signature = nacl.sign(Buffer.from(request.signatureInput, messageEncoding), naclKey.secretKey);
        } else {
          const seed = Uint8Array.from(Buffer.from(process.env.VALIDATOR_SEED,keyEncoding));
          const key = Key.fromSeed({ algorithm: KeyAlgorithm.Ed25519, seed });
          signature = key.signMessage({ message: Buffer.from(request.signatureInput, messageEncoding) });
        }
        request.setSignature({ signature: signature });
        const response: GetValidatorInfoResponse = await this.pool.submitAction(request)


        console.log(keyEncoding,messageEncoding,useNacl,response);
      } catch (error) {
        console.log(keyEncoding,messageEncoding,useNacl,error)
        this.logger.error(error);
    }
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncLedgers() {
    await Promise.all([
      this.syncLedger(0),
      this.syncLedger(1),
      this.syncLedger(2)
    ])
  }

  @Cron(process.env.CRON_EXPRESSION || CronExpression.EVERY_MINUTE)
  async syncStatus() {
    const status = await this.pool.status;
    console.log(status);
    await this.getValidatorInfo();
  }
}


