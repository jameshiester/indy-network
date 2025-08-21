import { GetTransactionResponse } from '@hyperledger/indy-vdr-nodejs';
import { IDid, mapRoleTypeToName } from 'model';

export const transactionResponseToDidAdapter = (
  response: GetTransactionResponse,
): Omit<IDid, 'createdAt' | 'updatedAt'> => {
  const {
    txn,
    // @ts-ignore
    txnMetadata: { txnId, txnTime },
  } = response.result.data;
  const txnData = txn.data as any;
  const did: Omit<IDid, 'createdAt' | 'updatedAt'> = {
    id: txnData.dest,
    from: txn.metadata.from as string,
    role: txnData.role,
    roleName: mapRoleTypeToName(txnData.role),
    verkey: txnData.verkey,
    alias: txnData.alias,
    transactionId: txnId,
    transactionTime: txnTime ? new Date(txnTime) : undefined,
  };
  return did;
};
