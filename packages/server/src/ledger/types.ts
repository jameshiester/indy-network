/**
 * Interface for the expected transaction response structure
 * This matches what the utility functions expect
 */
export interface GetTransactionResponse {
  type: '3';
  reqId: number;
  seqNo: number;
  txnTime: number;
  identifier: string;
  data: {
    auditPath: string[];
    txnMetadata: {
      seqNo: number;
      txnTime?: number;
      txnId?: string;
    };
    txn: {
      metadata: Record<string, unknown>;
      data: unknown;
      type: string;
    };
    rootHash: string;
    ver: string;
    ledgerSize: number;
    reqSignature: Record<string, unknown>;
  };
}
