import { GetTransactionResponse } from '@hyperledger/indy-vdr-nodejs';
import {
  IndyTransactionType,
  ITransaction,
  LedgerType,
  mapRoleTypeToName,
  mapTransactionTypeToName,
} from 'model';

export const transactionResponseToTransactionAdapter = (
  ledger: LedgerType,
  sequence: number,
  response: GetTransactionResponse,
): Omit<ITransaction, 'createdAt' | 'updatedAt'> => {
  const {
    txn,
    // @ts-ignore
    txnMetadata: { txnId, txnTime },
  } = response.result.data;
  const txnData = txn.data as any;
  const baseProps: Omit<ITransaction, 'createdAt' | 'updatedAt'> = {
    transactionType: txn.type as IndyTransactionType,
    transactionTypeName: mapTransactionTypeToName(txn.type),
    id: (response.result.seqNo || sequence) as number,
    ledger: ledger.valueOf(),
    transactionId: txnId,
    value: response.result,
    from: txn?.metadata?.from as string,
    transactionTime: txnTime ? new Date(txnTime) : undefined,
  };
  switch (txn.type) {
    case IndyTransactionType.NYM:
      return {
        ...baseProps,
        role: txnData.role,
        roleName: mapRoleTypeToName(txnData.role),
        destination: txnData.dest,
      };
    case IndyTransactionType.ATTRIB:
      return {
        ...baseProps,
        destination: txnData.dest as string,
      };
    case IndyTransactionType.NODE:
      return {
        ...baseProps,
        destination: txnData.dest as string,
      };
    case IndyTransactionType.CRED_DEF:
      return {
        ...baseProps,
        destination: txnId,
      };
    case IndyTransactionType.SCHEMA:
      return {
        ...baseProps,
        destination: txnData.data.name,
      };
    default:
      return {
        ...baseProps,
        destination: txnId,
      };
  }
};
