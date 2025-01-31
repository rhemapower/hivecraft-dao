import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create new DAO",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('dao-core', 'create-dao', [
        types.utf8("Test DAO"),
        types.utf8("A test DAO"),
        types.uint(100),
        types.uint(10)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result, '(ok true)');
  }
});

Clarinet.test({
  name: "Ensure can submit and vote on proposals",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('dao-core', 'submit-proposal', [
        types.uint(1),
        types.utf8("Test Proposal"),
        types.utf8("A test proposal"),
      ], deployer.address),
      Tx.contractCall('dao-core', 'vote', [
        types.uint(1),
        types.bool(true)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[0].result, '(ok true)');
    assertEquals(block.receipts[1].result, '(ok true)');
  }
});
