pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

// I implement Mastermind of original version. 6 colors is expressed by 6 digits 0-5.
template MastermindVariation() {
  // Public inputs
  signal input pubGuessA;
  signal input pubGuessB;
  signal input pubGuessC;
  signal input pubGuessD;
  signal input pubNumHit;
  signal input pubNumBlow;
  signal input pubSolHash;
  
  // Private
  signal input privateSolA;
  signal input privateSolB;
  signal input privateSolC;
  signal input privateSolD;
  signal input privateSalt;

  // Output
  signal output solHashOut;

  var guess[4] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD];
  var soln[4] = [privateSolA, privateSolB, privateSolC, privateSolD];
  component lessThan[8];
  component equalGuess[6];
  component equalSoln[6];
  var equalIdx = 0;

  // Create a constraint that the solution and guess digits are all less than 6.(6 colors)
  for (var j=0; j<4; j++) {
      lessThan[j] = LessThan(4);
      lessThan[j].in[0] <== guess[j];
      lessThan[j].in[1] <== 6;
      lessThan[j].out === 1;
      lessThan[j+4] = LessThan(4);
      lessThan[j+4].in[0] <== soln[j];
      lessThan[j+4].in[1] <== 6;
      lessThan[j+4].out === 1;
      for (var k=j+1; k<4; k++) {
          // Create a constraint that the solution and guess digits are unique. no duplication.
          equalGuess[equalIdx] = IsEqual();
          equalGuess[equalIdx].in[0] <== guess[j];
          equalGuess[equalIdx].in[1] <== guess[k];
          equalGuess[equalIdx].out === 0;
          equalSoln[equalIdx] = IsEqual();
          equalSoln[equalIdx].in[0] <== soln[j];
          equalSoln[equalIdx].in[1] <== soln[k];
          equalSoln[equalIdx].out === 0;
          equalIdx += 1;
      }
  }

  // count hit and blow
  var hitCount = 0;
  var blowCount = 0;
  component equalHitAndBlow[16];
  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 4; j ++) {
      equalHitAndBlow[4*i+j] = IsEqual();
      equalHitAndBlow[4*i+j].in[0] <== soln[i];
      equalHitAndBlow[4*i+j].in[1] <== guess[j];
      blowCount += equalHitAndBlow[4*i+j].out;
      if (j == i) {
        hitCount += equalHitAndBlow[4*i+j].out;
        blowCount -= equalHitAndBlow[4*i+j].out;
      }
    }
  }
  
  // Create a constraint around the number of hit
  component equalHit = IsEqual();
  equalHit.in[0] <== pubNumHit;
  equalHit.in[1] <== hitCount;
  equalHit.out === 1;
  
  // Create a constraint around the number of blow
  component equalBlow = IsEqual();
  equalBlow.in[0] <== pubNumBlow;
  equalBlow.in[1] <== blowCount;
  equalBlow.out === 1;

  // Verify that the hash of the private solution matches pubSolHash
  component poseidon = Poseidon(5);
  poseidon.inputs[0] <== privateSalt;
  poseidon.inputs[1] <== privateSolA;
  poseidon.inputs[2] <== privateSolB;
  poseidon.inputs[3] <== privateSolC;
  poseidon.inputs[4] <== privateSolD;

  solHashOut <== poseidon.out;
  pubSolHash === solHashOut;
}

component main { public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubNumHit, pubNumBlow, pubSolHash] }= MastermindVariation();