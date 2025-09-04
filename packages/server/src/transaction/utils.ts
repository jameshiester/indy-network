import {
  IndyRoleType,
  IndyTransactionType,
  ITransaction,
  LedgerType,
  mapRoleTypeToName,
  mapTransactionTypeToName,
} from 'model';

import { GetTransactionResponse } from '../ledger/types';

export const transactionResponseToTransactionAdapter = (
  ledger: LedgerType,
  sequence: number,
  response: GetTransactionResponse,
): Omit<ITransaction, 'createdAt' | 'updatedAt'> => {
  const {
    txn,
    txnMetadata: { txnId, txnTime },
  } = response.data;
  const txnData = txn.data as {
    role: IndyRoleType;
    dest: string;
    data: {
      name: string;
    };
  };
  const baseProps: Omit<ITransaction, 'createdAt' | 'updatedAt'> = {
    transactionType: txn.type as IndyTransactionType,
    transactionTypeName: mapTransactionTypeToName(txn.type),
    id: response.seqNo || sequence,
    ledger: ledger.valueOf(),
    transactionId: txnId,
    value: response.data,
    from: txn?.metadata?.from as string,
    transactionTime: txnTime ? new Date(txnTime) : undefined,
  };
  switch (txn.type as IndyTransactionType) {
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
        destination: txnData.dest,
      };
    case IndyTransactionType.NODE:
      return {
        ...baseProps,
        destination: txnData.dest,
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
