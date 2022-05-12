import Text "mo:base/Text";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Time "mo:base/Time";
import Logger "mo:ic-logger/Logger";

shared(msg) actor class LoggerController() {

    stable var state : Logger.State<Text> = Logger.new<Text>(0, null);
    let logger = Logger.Logger<Text>(state);

    public shared (msg) func append(msgs: [Text]) {
        logger.append(msgs);
    };
    
    public shared query (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {
        logger.view(from, to)
    };
}
