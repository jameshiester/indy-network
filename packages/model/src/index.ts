
export enum LedgerType {
    POOL = 0,
    DOMAIN = 1,
    CONFIG = 2,
}

export enum TransactionType {
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

export enum IndyRoleType {
    TRUSTEE = '0',
    STEWARD = '2',
    TGB = '100',
    ENDORSER = '101',
  }