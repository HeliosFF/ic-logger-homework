import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import List "mo:base/List";
import Array "mo:base/Array";
import Logger "mo:ic-logger/Logger";

shared(msg) actor class LoggerController() {

    var logNum = 0;
    var loggerMap = HashMap.HashMap<Text, Logger.Logger<Text>>(1000, Text.equal, Text.hash);

    public shared (msg) func append(msgs: [Text]) {
        for (msg in msgs.vals()) {
            var loggerIndex = Nat.toText(logNum / 100);
            let currentLogger = switch (loggerMap.get(loggerIndex)) {
                case null {
                    var initState : Logger.State<Text> = Logger.new<Text>(0, null);
                    let logger = Logger.Logger<Text>(initState);
                    loggerMap.put(loggerIndex, logger);
                    logger;
                };
                case (?l) { l; };
            };
            currentLogger.append([msg]);
            logNum := logNum + 1;
        }
    };

    public shared query (msg) func getView(listIndex: Nat) : async Logger.View<Text> {
        let currentLogger = switch (loggerMap.get(Nat.toText(listIndex))) {
            case null { throw Error.reject("wrong page number"); };
            case (?l) { l; };
        };
        currentLogger.view(0,99);
    };
    
    public shared query (msg) func view(from: Nat, to: Nat) : async Logger.View<Text> {
        assert(to >= from);
        var arr : [Text] = []; 

        var fromIndex = from / 2;
        var toIndex = to / 2;
        var gap :Int = toIndex - fromIndex;
        var currentIndex = fromIndex;

        if(gap != 0) {
            while(gap > 0){
                var logR : [Text] = [];
                let currentLogger = switch (loggerMap.get(Nat.toText(currentIndex))) {
                    case null { throw Error.reject("wrong page number"); };
                    case (?l) { l; };
                };
                if(currentIndex == fromIndex) {
                    logR := currentLogger.view(from%100, 99).messages;
                } else if(currentIndex == toIndex) {
                    logR := currentLogger.view(0, to%100).messages;
                } else {
                    logR := currentLogger.view(0, 99).messages;
                };
                currentIndex := currentIndex + 1;
                gap := gap - 1;
                arr := Array.append(arr,logR);
            };
        };
        if(gap == 0) {
            let currentLogger = switch (loggerMap.get(Nat.toText(currentIndex))) {
                case null { throw Error.reject("wrong page number"); };
                case (?l) { l; };
            };
            var logR = currentLogger.view(from%100, to%100).messages;
            arr := Array.append(arr,logR);
        };
        
        {
            start_index = from;
            messages = arr;
        };
    };
}
