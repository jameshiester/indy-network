#!/usr/bin/python3

import argparse
import os

from ledger.genesis_txn.genesis_txn_file_util import create_genesis_txn_init_ledger
from plenum.common.member.member import Member
from plenum.common.member.steward import Steward
from collections import OrderedDict

from plenum.common.types import f
from plenum.common.constants import TARGET_NYM, TXN_TYPE, DATA, ALIAS, ENC, RAW, HASH, \
    STEWARD, ROLE, TRUSTEE, VERKEY, TXN_TIME

import sys
import csv


REF = 'ref'
TRUST_ANCHOR = '101'
GET_ATTR = '104'
NONCE = 'nonce'
ATTRIB = '100'
ATTRIBUTES = "attributes"
ATTR_NAMES = "attr_names"
ACTION = 'action'
SCHEDULE = 'schedule'
TIMEOUT = 'timeout'
SHA256 = 'sha256'
START = 'start'
CANCEL = 'cancel'
COMPLETE = 'complete'
FAIL = 'fail'
JUSTIFICATION = 'justification'
SIGNATURE_TYPE = 'signature_type'

def getTxnOrderedFields():
    return OrderedDict([
        (f.IDENTIFIER.nm, (str, str)),
        (f.REQ_ID.nm, (str, int)),
        (f.SIG.nm, (str, str)),
        (TXN_TIME, (str, float)),
        (TXN_TYPE, (str, str)),
        (TARGET_NYM, (str, str)),
        (VERKEY, (str, str)),
        (DATA, (str, str)),
        (ALIAS, (str, str)),
        (RAW, (str, str)),
        (ENC, (str, str)),
        (HASH, (str, str)),
        (ROLE, (str, str)),
        (REF, (str, str)),
        (SIGNATURE_TYPE, (str, str))
    ])



def parse_trustees(trusteeFile):
   trustees = []
   with open(trusteeFile, newline='') as csvfile:
      reader = csv.DictReader(csvfile, delimiter=',')
      for row in reader:
         trustees.append({'name':row['Trustee name'], 'nym':row['Trustee DID'], 'verkey':row['Trustee verkey']})
   return trustees
         

def parse_stewards(stewardFile, trusteeDID):
   stewards = []
   nodes = []
   with open(stewardFile, newline='') as csvfile:
      reader = csv.DictReader(csvfile, delimiter=',')
      for row in reader:
         stewards.append({'nym':row['Steward DID'], 'verkey':row['Steward verkey'], 'auth_did':trusteeDID})
         nodes.append({'auth_did':row['Steward DID'], 'alias':row['Validator alias'], 'node_address':row['Node IP address'], 
                       'node_port':row['Node port'], 'client_address':row['Client IP address'], 
                       'client_port':row['Client port'], 'verkey':row['Validator verkey'], 
                       'bls_key':row['Validator BLS key'], 'bls_pop':row['Validator BLS POP']})
   return stewards, nodes


def open_ledger(pathname):
   baseDir = os.path.dirname(pathname)
   if baseDir == '':
      baseDir = './'
   else:
      baseDir = baseDir + '/'
   txnFile = os.path.basename(pathname)
   ledger = create_genesis_txn_init_ledger(baseDir, txnFile)
   ledger.reset()
   return ledger


def make_pool_genesis(pool_pathname, node_defs):
   pool_ledger = open_ledger(pool_pathname)   

   seq_no = 1
   for node_def in node_defs:
      txn = Steward.node_txn(node_def['auth_did'], node_def['alias'], node_def['verkey'],
                                  node_def['node_address'], node_def['node_port'], node_def['client_port'], 
                                  client_ip=node_def['client_address'], blskey=node_def['bls_key'],
                                  seq_no=seq_no, protocol_version=None, bls_key_proof=node_def['bls_pop'])
      pool_ledger.add(txn)
      seq_no += 1

   pool_ledger.stop()


def make_domain_genesis(domain_pathname, trustee_defs, steward_defs):
   domain_ledger = open_ledger(domain_pathname)
   
   seq_no = 1
   for trustee_def in trustee_defs:
      txn = Member.nym_txn(trustee_def['nym'], name=trustee_def['name'], verkey=trustee_def['verkey'], role=TRUSTEE,
                           seq_no=seq_no,
                           protocol_version=None)
      domain_ledger.add(txn)
      seq_no += 1   

   for steward_def in steward_defs:
      txn = Member.nym_txn(steward_def['nym'], verkey=steward_def['verkey'], role=STEWARD, 
                           creator=trustee_def['nym'],
                           seq_no=seq_no,
                           protocol_version=None)
      domain_ledger.add(txn)
      seq_no += 1
   
   domain_ledger.stop()


# --- MAIN ---

import os

# Read required environment variables
trustees_csv = os.environ.get('TRUSTEES_CSV','/var/input/trustee_file.csv')
stewards_csv = os.environ.get('STEWARDS_CSV','/var/input/steward_file.csv')
# Optional output paths with defaults
pool_path = os.environ.get('POOL_TRANSACTIONS_PATH', '/var/output/pool_transactions')
domain_path = os.environ.get('DOMAIN_TRANSACTIONS_PATH', '/var/output/domain_transactions')


trustee_defs = parse_trustees(trustees_csv)
steward_defs, node_defs = parse_stewards(stewards_csv, trustee_defs[0]["nym"])   # The first trustee 'onboards' all stewards

make_pool_genesis(pool_path, node_defs)
make_domain_genesis(domain_path, trustee_defs, steward_defs)

