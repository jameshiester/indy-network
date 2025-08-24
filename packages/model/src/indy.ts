export enum LedgerType {
  POOL = 0,
  DOMAIN = 1,
  CONFIG = 2,
}

export enum IndyTransactionType {
  NODE = '0',
  NYM = '1',
  ATTRIB = '100',
  SCHEMA = '101',
  CRED_DEF = '102',
  DISCLO = '103',
  GET_ATTR = '104',
  GET_NYM = '105',
  GET_SCHEMA = '107',
  GET_CLAIM_DEF = '108',
  POOL_UPGRADE = '109',
  NODE_UPGRADE = '110',
  POOL_CONFIG = '111',
  CHANGE_KEY = '112',
  REVOC_REG_DEF = '113',
  RECOV_REG_ENTRY = '114',
  POOL_RESTART = '118',
  AUTH_RULE = '120',
}

export const mapTransactionTypeToName = (type?: string): string | undefined => {
  if (!type) return undefined;
  const transactionType = Object.entries(IndyTransactionType).find(
    (transactionType) => transactionType[1] === type,
  );
  if (!transactionType) {
    return undefined;
  }
  return transactionType[0];
};

export const mapRoleTypeToName = (type?: string): string | undefined => {
  if (!type) return undefined;
  const role = Object.entries(IndyRoleType).find(
    (roleType) => roleType[1] === type,
  );
  if (!role) {
    return undefined;
  }
  return role[0];
};

export enum IndyRoleType {
  TRUSTEE = '0',
  STEWARD = '2',
  TGB = '100',
  ENDORSER = '101',
}

export interface INode {
  name: string;
  active: boolean;
  value?: unknown;
  indyVersion?: string;
  did?: string;
  verkey?: string;
  uptimeSeconds?: number;
  ClientAddress?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface ITransaction {
  id: number;
  ledger: number;
  transactionType?: IndyTransactionType;
  transactionTypeName?: string;
  role?: IndyRoleType;
  roleName?: string;
  transactionId?: string;
  value?: unknown;
  from?: string;
  destination?: string;
  transactionTime?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface IDid {
  id: string;
  from?: string;
  role?: IndyRoleType;
  verkey?: string;
  alias?: string;
  transactionId?: number;
  roleName?: string;
  attributes?: any;
  transactionTime?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface INodeHistory {
  id?: number;
  name?: string;
  timestamp?: Date;
  indyVersion?: string;
  readThroughput?: number;
  writeThroughput?: number;
  reachableNodesCount?: number;
  unreachableNodesCount?: number;
  active?: boolean;
}

// Validator Info Interfaces
export interface IValidatorStatus {
  ok: boolean;
  timestamp: string;
  node_timestamp: number;
  uptime: string;
  software: {
    'indy-node': string;
    sovrin: string;
  };
  errors: number;
  warnings: number;
}

export interface IValidatorMetrics {
  Delta: number;
  Lambda: number;
  Omega: number;
  'instances started': Record<string, number>;
  'ordered request counts': Record<string, number>;
  'ordered request durations': Record<string, number>;
  'max master request latencies': number;
  'client avg request latencies': Record<string, number | null>;
  throughput: Record<string, number>;
  'master throughput': number | null;
  'total requests': number;
  'avg backup throughput': number;
  'master throughput ratio': number | null;
  'average-per-second': {
    'read-transactions': number;
    'write-transactions': number;
  };
  'transaction-count': {
    ledger: number;
    pool: number;
    config: number;
    audit: number;
  };
  uptime: number;
}

export interface IValidatorNodeInfo {
  Name: string;
  Mode: string;
  Client_port: number;
  Client_ip: string;
  Client_protocol: string;
  Node_port: number;
  Node_ip: string;
  Node_protocol: string;
  did: string;
  verkey: string;
  BLS_key: string;
  Metrics: IValidatorMetrics;
  Committed_ledger_root_hashes: Record<string, string>;
  Committed_state_root_hashes: Record<string, string>;
  Uncommitted_ledger_root_hashes: Record<string, unknown>;
  Uncommitted_ledger_txns: Record<string, { Count: number }>;
  Uncommitted_state_root_hashes: Record<string, string>;
  View_change_status: {
    View_No: number;
    VC_in_progress: boolean;
    Last_view_change_started_at: string;
    Last_complete_view_no: number;
    IC_queue: Record<string, unknown>;
    VCDone_queue: Record<string, unknown>;
  };
  Catchup_status: {
    Ledger_statuses: Record<string, string>;
    Received_LedgerStatus: string;
    Waiting_consistency_proof_msgs: Record<string, unknown>;
    Number_txns_in_catchup: Record<string, number>;
    Last_txn_3PC_keys: Record<string, Record<string, [unknown, unknown]>>;
  };
  Freshness_status: Record<
    string,
    {
      Last_updated_time: string;
      Has_write_consensus: boolean;
    }
  >;
  Requests_timeouts: {
    Propagates_phase_req_timeouts: number;
    Ordering_phase_req_timeouts: number;
  };
  Count_of_replicas: number;
  Replicas_status: Record<
    string,
    {
      Primary: string;
      Watermarks: string;
      Last_ordered_3PC: [number, number];
      Stashed_txns: {
        Stashed_checkpoints: number;
        Stashed_PrePrepare: number;
      };
    }
  >;
}

export interface IValidatorPoolInfo {
  Read_only: boolean;
  Total_nodes_count: number;
  f_value: number;
  Quorums: string;
  Reachable_nodes: Array<[string, number | null]>;
  Unreachable_nodes: string[];
  Reachable_nodes_count: number;
  Unreachable_nodes_count: number;
  Blacklisted_nodes: string[];
  Suspicious_nodes: string;
}

export interface IValidatorHardware {
  HDD_used_by_node: string;
}

export interface IValidatorSoftware {
  OS_version: string;
  Installed_packages: string[];
  Indy_packages: string[];
  'indy-node': string;
  sovrin: string;
}

export interface IValidatorExtractions {
  journalctl_exceptions: string[];
  'indy-node_status': string[];
  'node-control status': string[];
  upgrade_log: string;
  stops_stat: unknown;
}

export interface IValidatorResponse {
  op: string;
  result: {
    type: string;
    identifier: string;
    reqId: number;
    data: {
      'response-version': string;
      timestamp: number;
      Hardware: IValidatorHardware;
      Pool_info: IValidatorPoolInfo;
      Protocol: Record<string, unknown>;
      Node_info: IValidatorNodeInfo;
      Software: IValidatorSoftware;
      Update_time: string;
      Memory_profiler: unknown[];
      Extractions: IValidatorExtractions;
    };
  };
}

export interface IValidatorInfo {
  name: string;
  network: string;
  'client-address': string;
  'node-address': string;
  status: IValidatorStatus;
  response: IValidatorResponse;
}
