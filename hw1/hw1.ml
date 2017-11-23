open List

type ('a, 'b) symbol = N of 'a | T of 'b

let subset a b = 
    for_all ( fun x -> mem x b) a 

let equal_sets a b = 
    subset a b && subset b a

let set_union a b = 
    append a b;;

let set_intersection a b = 
    filter( fun x -> mem x b ) a 

let set_diff a b = 
    filter ( fun x -> not (mem x b )) a 

let rec computed_fixed_point eq f x = 
    match eq x (f x) with
        true -> x
    |   false -> computed_fixed_point eq f (f x)
  

let rec computed_periodic_helper f p x = 
    match p with
        0 -> x
    |   _ -> computed_periodic_helper f (p-1) (f x)

let rec computed_periodic_point eq f p x  = 
    match eq x (computed_periodic_helper f p x) with 
        true -> x 
    |   false -> computed_periodic_point eq f p (f x )
    

let rec while_away s p x = 
    match (p x) with
        false -> []
    |   true -> [x] @ (while_away s p (s x))

let rec rle_decode_helper (a,b) = 
    match a with 
        0 -> []
    |   _ -> [b] @ rle_decode_helper (a-1,b)


let rec rle_decode lp = 
    match lp with 
        [] -> []
    |   _ -> rle_decode_helper (hd lp) @ rle_decode (tl lp)

let in_grammar g x = 
    match g with 
        (_, []) -> false
        |  _ -> let (s,r) = g in (
                    let (a,b) = split r in (
                        exists (fun y -> N y = x) a 
                    ))


let rec build_valid_rules (g,ng) = 
    let new_grammar = 
        let (s,r) = g in (s,
        filter ( fun x -> match x with 
                            (_, y) -> for_all ( fun z -> match z with 
                                                            T _ -> true
                                                        |   N _ -> in_grammar ng z ) y) r ) 
        in (
        g, new_grammar
        )

let grammar_compare (a,b) (c,d) = 
    let (e,f) = b in (
        let (g,h) = d in (
            equal_sets f h 
    ))
    
    
let rec filter_blind_alleys g = 

    let (o,n) = (
    let (a,b) = g in (
        computed_fixed_point( grammar_compare ) build_valid_rules (g, (a,[]))
    ) 
    )in n 







