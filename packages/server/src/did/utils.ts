import { GetTransactionResponse } from '@hyperledger/indy-vdr-nodejs';
import { IDid, IndyRoleType, mapRoleTypeToName } from 'model';

export const transactionResponseToDidAdapter = (
  response: GetTransactionResponse['result'],
): Omit<IDid, 'createdAt' | 'updatedAt'> => {
  const {
    txn,
    // @ts-expect-error txnMetadata is not typed correctly.
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
    transactionTime: txnTime ? new Date(txnTime as string) : undefined,
  };
  return did;
};
