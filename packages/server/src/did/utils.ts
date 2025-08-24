import { IDid, IndyRoleType, mapRoleTypeToName } from 'model';
import { GetTransactionResponse } from '../ledger/types';

export const transactionResponseToDidAdapter = (
  response: GetTransactionResponse,
): Omit<IDid, 'createdAt' | 'updatedAt'> => {
  const {
    txn,
    txnMetadata: { seqNo, txnTime },
  } = response.data;
  const txnData = txn.data as {
    dest: string;
    role: IndyRoleType;
    verkey: string;
    alias: string;
  };
  const did: Omit<IDid, 'createdAt' | 'updatedAt'> = {
    id: txnData.dest,
    from: txn.metadata.from as string,
    role: txnData.role,
    roleName: mapRoleTypeToName(txnData.role),
    verkey: txnData.verkey,
    alias: txnData.alias,
    transactionId: seqNo,
    transactionTime: txnTime ? new Date(txnTime) : undefined,
  };
  return did;
};
