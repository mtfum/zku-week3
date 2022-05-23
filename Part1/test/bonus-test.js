// [bonus] unit test for bonus.circom
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

describe('SimplePoker', function () {
	it('Player 1 should win', async () => {
		const circuit = await wasm_tester(
			path.join(
				__dirname,
				'..',
				'contracts',
				'circuits',
				'bonus.circom'
			)
		);
		await circuit.loadConstraints();
		const poseidonJs = await buildPoseidon();

    const testCase = {
      cards: ,
		};
		const salt = ethers.BigNumber.from(ethers.utils.randomBytes(32));
		const solutionHash = ethers.BigNumber.from(
			poseidonJs.F.toObject(poseidonJs([salt, ...testCase.guess]))
		);
		const INPUT = {
			cards: [
        [13, 13, 11, 10, 9],
        [1, 4, 11, 10, 9],
        [2, 5, 2, 8, 6]
      ],
			privateSalt: salt,
		};
		const witness = await circuit.calculateWitness(INPUT, true);
		assert(Fr.eq(Fr.e(witness[0]), Fr.e(1)));
	});
});
