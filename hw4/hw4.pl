%Implementation of signal_morse

%Predicate to generate run-length encoding of input
generate_rle([],[]). %return an empty list if the input is empty
generate_rle([H], [[H,1]]). %base case, if the list has one element, return count of 1. 
generate_rle([H|T], [[H,C] | R]) :- generate_rle(T, [[H,C1] | R]), C is C1+1, !.  %recursively call gen_rle to count occurences if 1st item is same as second item
generate_rle([H|T], [[H, 1], [X,C] |R]) :- generate_rle(T, [[X,C] | R]), !. %if the 1st item in the list is different then the second, we match this case

%Predicate to match each element of the rle with the appropriate symbol, preferring the shortest alternative in case of ambivalence

try_match([], []).
try_match([[1,1] | T], ['.' | R]):- try_match(T, R).
try_match([[1,2] | T], ['.' | R]):- try_match(T, R).
try_match([[1,2] | T], ['-' | R]):- try_match(T, R).
try_match([[1,3] | T], ['-' | R]):- try_match(T, R).
try_match([[1,O] | T], ['-' | R]):- O > 3, try_match(T, R).
try_match([[0,1] | T], R):- try_match(T, R).
try_match([[0,2] | T], R):- try_match(T, R).
try_match([[0,2] | T], ['^' | R]):- try_match(T, R).
try_match([[0,3] | T], ['^' | R]):- try_match(T, R).
try_match([[0,4] | T], ['^' | R]):- try_match(T, R).
try_match([[0,5] | T], ['^' | R]):- try_match(T, R).
try_match([[0,5] | T], ['#' | R]):- try_match(T, R).
try_match([[0,O] | T], ['#' | R]):- O > 5, try_match(T, R).

%Predicate the generates the rle, then matches the encoding to symbols. 
signal_morse([], []).
signal_morse([H|T], M):- generate_rle([H|T], R), try_match(R, M).

%Implementation of signal_message

%Morse dictionary
morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

%Predicate to retrieve the signal group representing the next symbol. If it is terminated by a '#', the '#' is kept in the signal remainder
get_first_symbol(Signal, Symbol, Remainder) :- get_first_symbol(Signal, [], Symbol, Remainder).
get_first_symbol([],A,A,[]).
get_first_symbol(['#'|T] ,A,A,R):- append(['#'],T,R),!.
get_first_symbol(['^'|T], A,A,T).
get_first_symbol([H|T],A,S,R):- append(A,[H],NA), get_first_symbol(T,NA,S,R),!.

%Predicate to parse a signal into a message
parse_signal(Signal, Message) :- parse_signal(Signal, [], Message).
parse_signal([], A, A).
parse_signal(['#'|T],A,M):- append(A, ['#'], NA), parse_signal(T, NA, M).
parse_signal(Signal, A, M):- get_first_symbol(Signal, Symbol, Remainder), morse(T, Symbol), append(A, [T], NA), parse_signal(Remainder,NA,M).

%Predicate to remove errors from parse message
rem_errors([],[]).
rem_errors(Input, Message):- rem_errors(Input, [], [], Message),!.
rem_errors([], A, A2, M):- append(A, A2, M).
rem_errors(['#'|T], A, A2, M):- append(A2, ['#'], NA2), append(A, NA2, NA), rem_errors(T, NA, [], M).
rem_errors([error|T], A, [], M):- append(A, [error], NA), rem_errors(T, NA, [], M).
rem_errors([error|T], A, [_|_], M) :- rem_errors(T, A, [], M).
rem_errors([H|T], A, A2, M):- append(A2, [H], NA2), rem_errors(T, A, NA2, M).

signal_message([],[]).
signal_message(Input, Message) :- signal_morse(Input, Morse), parse_signal(Morse, Raw), rem_errors(Raw, Message).
	