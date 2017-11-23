open List

type ('terminal, 'nonterminal) symbol =
    | T of 'terminal
    | N of 'nonterminal

(*
 * This helper function for convert_grammar builds an association list out of the rules in the given grammar
 *)
let rec arrange_rules rules = match rules with
    | [] -> []
    | (symbol, rhs)::tail -> 
        let arranged = (arrange_rules (tl rules)) in 
            if mem_assoc symbol arranged then 
                (symbol, rhs::assoc symbol arranged)::(remove_assoc symbol arranged)
            else
                (symbol, rhs::[])::arranged

(*
 * convert_grammar utilizes List.assoc to create the function that match symbols to the list of rhs in the production function
 *)

let convert_grammar gram1 = 
    let ( start, rules ) = gram1 in 
        let f list key = assoc key list in 
            (start, f (arrange_rules rules))
        


let rec rule_matcher symbol rule_function rule_list baggage acceptor derivation fragment = 
    match rule_list with  
        | [] ->None
        | first_rule::rest_rules -> match (fragment_matcher rule_function (first_rule@baggage) acceptor (derivation@[symbol, first_rule]) fragment) with
            | None -> rule_matcher symbol rule_function rest_rules baggage acceptor derivation fragment
            | Some res -> Some res 
and 
fragment_matcher rule_function rule acceptor derivation fragment = 
	match rule with
        | [] -> acceptor derivation fragment
        | _ -> match fragment with
            | [] -> None
            | frag_head::frag_tail -> match rule with
                | [] -> None
                | (N new_symbol)::rule_tail -> if (length derivation) > 100 * (length fragment) then None else
                    (rule_matcher new_symbol rule_function (rule_function new_symbol) rule_tail acceptor derivation fragment)
				| (T terminal)::rule_tail -> if frag_head = terminal then (fragment_matcher rule_function rule_tail acceptor derivation frag_tail) else None
                
					
					

let parse_prefix gram acceptor fragment = 
	let (start, rule_function) = gram in 
		(rule_matcher start rule_function (rule_function start) [] acceptor [] fragment)

