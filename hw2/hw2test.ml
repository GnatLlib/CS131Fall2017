type mygrammar_nonterminals = 
    | Start | Symbol | Even | Odd 

let mygrammar = 
    ( Start,
    function 
        | Start-> [[N Start; N Symbol];
                     [N Odd]]
        | Symbol -> [[N Even ; N Odd];
                     [N Odd; N Even]]
        | Even -> [[T 0];[T 2];[T 4];[T 6];[T 8]]
        | Odd -> [[T 1]; [T 3];[T 5];[T 7];[T 9]]           
                     )

let accept_any derivation frag = Some (derivation, frag)


let test_1 = 
    ((parse_prefix mygrammar accept_any [1;3;4] ) = 
    Some( [ (Start, [N Start; N Symbol]); (Start, [N Odd]); (Odd, [T 1]);
            (Symbol, [N Odd; N Even]); (Odd, [T 3]); (Even, [T 4]) ], []))


let accept_at_least_one derivation frag = 
    if (length frag) > 0 then Some (derivation, frag) else None

let mygrammar2 = 
    ( Start,
    function 
        | Start-> [[N Symbol; N Start];
                     [N Odd]]
        | Symbol -> [[N Even ; N Odd];
                     [N Odd; N Even]]
        | Even -> [[T 0];[T 2];[T 4];[T 6];[T 8]]
        | Odd -> [[T 1]; [T 3];[T 5];[T 7];[T 9]]           
                     )

let test_2 = 
    ((parse_prefix mygrammar2 accept_at_least_one [1;4;5] ) = 
    Some ([(Start, [N Odd]); (Odd, [T 1])], [4; 5])
)
