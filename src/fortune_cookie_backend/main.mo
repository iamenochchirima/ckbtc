import Result "mo:base/Result";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Error "mo:base/Error";
import CkBtcLedger "canister:ckbtc_ledger";
import Types "types";
import { createInvoice; toAccount; toSubaccount } "utils";

actor FortuneCookie {

  let cookies = [
    "A smooth sea never made a skilled sailor.",
    "The early bird gets the worm, but the second mouse gets the cheese.",
    "You will find happiness with a new perspective.",
    "Hard work pays off in the future; laziness pays off now.",
    "An unexpected visitor will bring you good news.",
    "Your talents will be recognized and rewarded.",
    "The best way to predict the future is to create it.",
    "Good things come to those who wait, but better things come to those who take action.",
    "You will travel to exciting places in the near future.",
    "A problem well-stated is a problem half-solved.",
    "The journey of a thousand miles begins with a single step.",
    "You will soon be surrounded by friends and laughter.",
    "Opportunity knocks softly, listen carefully.",
    "The best is yet to come.",
    "Your efforts will be rewarded handsomely.",
    "Keep your face to the sunshine, and you cannot see a shadow.",
    "Happiness is not something ready-made, it comes from your own actions.",
    "You are the architect of your destiny.",
    "You will soon embark on a new adventure.",
    "A cheerful letter or message is on its way to you.",
    "Success is the sum of small efforts repeated day in and day out.",
    "Your creativity will lead to great success.",
    "Dream big and dare to fail.",
    "You are stronger than you think.",
    "Believe in yourself, and you will be unstoppable.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "You will make a positive difference in someone's life today.",
    "Your hard work will pay off in the long run.",
    "The best way out is always through.",
    "A pleasant surprise is waiting for you.",
    "Your future is bright.",
    "You are capable of amazing things.",
    "Good fortune is smiling upon you.",
    "Your kindness will lead to unexpected blessings.",
    "Adventure awaits you around the corner.",
    "You will find joy in simple pleasures.",
    "Embrace change; it will bring you new opportunities.",
    "Your wisdom will guide you to success.",
    "Trust your instincts; they will not lead you astray.",
    "The world is full of beauty, just like you.",
    "You are a beacon of positivity to those around you.",
    "Your life will be enriched by new experiences.",
    "You will find peace and contentment in the days ahead.",
    "Challenges are opportunities in disguise.",
    "Your determination will open doors to new opportunities.",
    "You are destined for greatness.",
    "Luck is on your side today.",
    "You will achieve great things in due time.",
    "Your future is filled with unlimited possibilities.",
  ];

  public shared ({ caller }) func getCookie() : async Result.Result<Text, Text> {
    // check ckBTC balance of the callers dedicated account
    let balance = await CkBtcLedger.icrc1_balance_of(
      toAccount({ caller; canister = Principal.fromActor(FortuneCookie) })
    );

    if (balance < 100) {
      return #err("Not enough funds available in the Account. Make sure you send at least 100 ckSats.");
    };

    try {
      // if enough funds were sent, move them to the canisters default account
      let transferResult = await CkBtcLedger.icrc1_transfer(
        {
          amount = balance - 10;
          from_subaccount = ?toSubaccount(caller);
          created_at_time = null;
          fee = ?10;
          memo = null;
          to = {
            owner = Principal.fromActor(FortuneCookie);
            subaccount = null;
          };
        }
      );

      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Couldn't transfer funds to default account:\n" # debug_show (transferError));
        };
        case (_) {};
      };
    } catch (error : Error) {
      return #err("Reject message: " # Error.message(error));
    };

    return #ok("Cookie:" # cookies[Int.abs(Time.now() / 1000) % 50]);
  };

  public shared ({ caller }) func getInvoice() : async Types.Invoice {
    createInvoice(toAccount({ caller; canister = Principal.fromActor(FortuneCookie) }), 100);
  };
};
