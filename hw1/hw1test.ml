let my_subset_test0 = subset [1;1;2;4] [4;2;1;7;8;9]

let my_equal_sets_test0 = equal_sets [4;1;2;2] [2;1;4]

let my_set_union_test0 = equal_sets ( set_union [5] [6] ) [5;6;6]

let my_set_intersection_test0 = equal_sets( set_intersection [5;6;6] [6;7]) [6]

let my_set_diff_test0 = equal_sets ( set_diff [1;2;3;4;4] [1;2;3] ) [4]

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x - x) 1000 = 0

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x * -1) 2 4 = 4

let my_while_away_test0 = while_away (fun x -> x-10) ((<) 0 ) 21 = [21;11;1]

let my_rle_decode_test0 = rle_decode[4,"a" ; 2,"b"; 0,"c"] = ["a"; "a"; "a"; "a"; "b"; "b"]
type test_nonterminals = 
    | Awesome | Cool | Neat

let test_grammar = 
    Awesome,
    [ Awesome, [T "behehe"];
        Cool, [T "asdfj"];
        Cool, [N Neat]]

let my_filter_blind_alleys_test0 = 
    filter_blind_alleys test_grammar = (Awesome, [ Awesome, [T "behehe"];
        Cool, [T "asdfj"]])

    