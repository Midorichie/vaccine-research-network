import { Tx, Chain, Account, types } from "./deps.ts";

const CONTRACT_NAME = 'vaccine-network';
const MOCK_RESEARCH_TOKEN = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.research-token';

Clarinet.test({
    name: "Ensures researcher registration succeeds with sufficient token balance",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const researcher = accounts.get('wallet_1')!;
        const institution = "Harvard Medical School";

        const block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'register-researcher',
                [
                    types.ascii(institution),
                    types.principal(MOCK_RESEARCH_TOKEN)
                ],
                researcher.address
            )
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Ensures researcher registration fails with insufficient token balance",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const researcher = accounts.get('wallet_2')!;
        const institution = "MIT";

        const block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'register-researcher',
                [
                    types.ascii(institution),
                    types.principal(MOCK_RESEARCH_TOKEN)
                ],
                researcher.address
            )
        ]);

        block.receipts[0].result.expectErr().expectUint(1004); // ERR-INSUFFICIENT-FUNDS
    }
});

Clarinet.test({
    name: "Ensures genome data submission succeeds with valid data",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const researcher = accounts.get('wallet_1')!;
        const genomeId = "GENOME123456789012";
        const dataHash = "0123456789012345678901234567890123456789012345678901234567890123";
        const genomeType = "mRNA-vaccine-target";

        // First register the researcher
        let block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'register-researcher',
                [
                    types.ascii("Harvard Medical School"),
                    types.principal(MOCK_RESEARCH_TOKEN)
                ],
                researcher.address
            )
        ]);

        // Then submit genome data
        block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'submit-genome-data',
                [
                    types.ascii(genomeId),
                    types.ascii(dataHash),
                    types.ascii(genomeType),
                    types.principal(MOCK_RESEARCH_TOKEN)
                ],
                researcher.address
            )
        ]);

        block.receipts[0].result.expectOk();
    }
});

Clarinet.test({
    name: "Ensures genome data submission fails with invalid genome ID length",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const researcher = accounts.get('wallet_1')!;
        const genomeId = "SHORT"; // Less than 10 chars
        const dataHash = "0123456789012345678901234567890123456789012345678901234567890123";
        const genomeType = "mRNA-vaccine-target";

        const block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'submit-genome-data',
                [
                    types.ascii(genomeId),
                    types.ascii(dataHash),
                    types.ascii(genomeType),
                    types.principal(MOCK_RESEARCH_TOKEN)
                ],
                researcher.address
            )
        ]);

        block.receipts[0].result.expectErr().expectUint(1002); // ERR-INVALID-SUBMISSION
    }
});

Clarinet.test({
    name: "Ensures validator addition succeeds when called by contract owner",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const validator = accounts.get('wallet_2')!;
        
        const block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'add-validator',
                [
                    types.principal(validator.address),
                    types.uint(10)
                ],
                deployer.address
            )
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Ensures validator addition fails when called by non-owner",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const nonOwner = accounts.get('wallet_1')!;
        const validator = accounts.get('wallet_2')!;
        
        const block = chain.mineBlock([
            Tx.contractCall(
                CONTRACT_NAME,
                'add-validator',
                [
                    types.principal(validator.address),
                    types.uint(10)
                ],
                nonOwner.address
            )
        ]);

        block.receipts[0].result.expectErr().expectUint(1001); // ERR-UNAUTHORIZED
    }
});
