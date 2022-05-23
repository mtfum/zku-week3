// [bonus] implement an example game from part d
include “../node_modules/circomlib/circuits/gates.circom”;
include “../node_modules/circomlib/circuits/comparators.circom”;

template SimplePoker(nCards) {
  signal input cards[nCards][5];
  signal input salt;
  signal output winnerIndex;
  signal output isDraw;

  // calculate pairs
  component pairs[nCards]
  var pairs: [[number]] = []
  for (var i = 0; i < nCards; i++) {
    pairs[i] = PairCalculator()
    pairs[i].cards = cards[i]

    pairs[i] = pairs[i].out
  }





  component myResult = PairCalculator()
  myResult.cards = myCards

  component opponentResult = PairCalculator()
  opponentResult.cards = opponentCards



}

template PairCalculator {
  signal input cards[5];
  signal output pairCards[2];

  // calculate my pairs
  var pairs: [2]; // the value of pair cards, maximum 2;
  var count = 0;
  for (var i = 0; i < 4; i++) {
    for (var j =i+1; j < 5; j++) {
      if (inputCards[i] == inputCards[j]) {
        
        if (pairs[count] != inputCards[i]) {
          count++;
          pairs[count] <== inputCards[i];
        }
        if (count == 2) {
          i = 5;
          j = 5;
        }
      }
    }
  }

  // Verify that the 


  pairCards <== pairs;
}


component main { public [cards, salt] } = SimplePoker(2);
