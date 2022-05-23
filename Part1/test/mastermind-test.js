//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const { assert } = require('chai');
const path = require('path');
const wasm_tester = require('circom_tester').wasm;
const buildPoseidon = require('circomlibjs').buildPoseidon;

const F1Field = require('ffjavascript').F1Field;
const Scalar = require('ffjavascript').Scalar;
const Fr = new F1Field(
	Scalar.fromString(
		'21888242871839275222246405745257275088548364400416034343698204186575808495617'
	)
);

describe('Hit And Blow', function () {
	it('mastermind-test', async () => {
		const circuit = await wasm_tester(
			path.join(
				__dirname,
				'..',
				'contracts',
				'circuits',
				'MastermindVariation.circom'
			)
		);
		await circuit.loadConstraints();
		const poseidonJs = await buildPoseidon();

		const testCase = {
			guess: [1, 2, 3, 4],
			sol: [1, 2, 3, 4],
			hit: 4,
			blow: 0,
		};
		const salt = ethers.BigNumber.from(ethers.utils.randomBytes(32));
		const solutionHash = ethers.BigNumber.from(
			poseidonJs.F.toObject(poseidonJs([salt, ...testCase.guess]))
		);
		const INPUT = {
			pubGuessA: testCase.guess[0],
			pubGuessB: testCase.guess[1],
			pubGuessC: testCase.guess[2],
			pubGuessD: testCase.guess[3],
			pubNumHit: testCase.hit,
			pubNumBlow: testCase.blow,
			pubSolHash: solutionHash,
			privateSolA: testCase.sol[0],
			privateSolB: testCase.sol[1],
			privateSolC: testCase.sol[2],
			privateSolD: testCase.sol[3],
			privateSalt: salt,
		};
		const witness = await circuit.calculateWitness(INPUT, true);
		assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
	});
});
