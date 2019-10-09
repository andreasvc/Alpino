%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 1992, 1993 Gertjan van Noord RUG %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(pack,[]).

:- use_module( memo ).

clean :-
	clean_up_memo,
	retractall(dtree(_,_,_)).

count :-
	count(Memo+E),
	write(Memo), write(' memo edges'),nl,
	write(E),    write(' derivation tree edges'),nl.

count(Memo+E) :-
        memo_count(Memo),
	hdrug_util:count_edges(pack:dtree(_,_,_),E).

lst :-
	listing(dtree).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% the real stuff %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse(o(tree(Cat,_Mrk,[]),String,Sem)) :-
	length(String,Max),
	user:user_sem(Cat,Sem),
	user:address(Cat,root),
	memo(pack:parse(subs_head(Cat,[]),0,Max,0,Max,root)),
	recover(subs_head(Cat,[]),0,Max,0,Max,root).

% parse(+CatExpr,?Begin,?End,+BeginExtreme,+EndExtreme)
% Catexpr is one of 
% lex_head(Word,ToParse)
% subs_head(Cat,ToParse) 
% e_head(Cat,ToParse)
parse(subs_head(Cat,ToParse),P0,P,E0,E,Target):-
	user:ign_init(Cat,Add,_Word,DownToParse,Name,Q0,Q),
	E0 =< Q0, Q =< E,
	hc_no_adjoin(DownToParse,_,Mid,Q0,Q,R0,R,E0,E,[],[],Name),
	hc_no_adjoin(    ToParse,Mid,_,R0,R,P0,P,E0,E,[],[dtree(Target,Add,Name)],Target).

parse(lex_head(Word/Q0,ToP),P0,P,E0,E,Target):-
	user:lex(Word,Q0,Q),
	E0 =< Q0, Q =< E,
	hc_no_adjoin(ToP,_,_,Q0,Q,P0,P,E0,E,[],[],Target).

parse(e_head(Cat,ToP),P0,P,E0,E,Target):-
	hdrug_util:between(E0,E,Q),
	hc(ToP,Cat,_,Q,Q,P0,P,E0,E,[],[],Target).

hc(ToDo,Cat0,Cat,P0,P,Q0,Q,E0,E,U,D,T) :-
	user:unify_node(Cat0),
	hc_no_adjoin(ToDo,Cat0,Cat,P0,P,Q0,Q,E0,E,U,D,T).

% case 1: finished
hc_no_adjoin([],Cat,Cat,P0,P,P0,P,_,_,_,Deriv,_) :- 
	assert_deriv(Deriv).

% case 2: go one level up in your own tree
hc_no_adjoin([t(Mid,L,R)|T],_,Goal,QL,QR,P0,P,E0,E,U,D,Target) :-
	parse_l(L,Q0,QL,E0,Target),
	parse_r(R,QR,Q,E,Target),
	hc(T,Mid,Goal,Q0,Q,P0,P,E0,E,U,D,Target).

% case 3: adjunction takes place at the current node
hc(ToParse,Small,Goal,QL,QR,P0,P,E0,E,U,Ds,Target) :-
	user:ign_aux(Small,Add,_,OwnToParse,Name,R0,R),
	user:check_lex(R0,R,E0,QL,QR,E,U),
	hc_no_adjoin(OwnToParse,_Foot,Mid,QL,QR,QLL,QRR,E0,E,[R0|U],[],Name),
	hc_no_adjoin(ToParse,Mid,Goal,QLL,QRR,P0,P,E0,E,U,[dtree(Target,Add,Name)|Ds],Target).

% parse_l(+RevDs,?Q0,+Q,+LeftExtreme)
parse_l([],Q,Q,_,_).
parse_l([H|T],Q0,Q,E0,Tr):-
	memo(pack:parse(H,Q1,Q,E0,Q,Tr)),
	parse_l(T,Q0,Q1,E0,Tr).

% parse_r(+Ds,+Q0,?Q,+RightExtreme)
parse_r([],Q,Q,_,_).
parse_r([H|T],Q0,Q,E,Tr):-
	memo(pack:parse(H,Q0,Q1,Q0,E,Tr)),
	parse_r(T,Q1,Q,E,Tr).

assert_deriv([]).
assert_deriv([H|T]) :-
	( \+ H -> assertz(H) ; true ),
	assert_deriv(T).

recover(subs_head(Cat,ToParse),P0,P,E0,E,Target):-
	user:address(Cat,Add),
	dtree(Target,Add,Name),
	user:init(Cat,Add,_Word,DownToParse,Name,Q0,Q),
	E0 =< Q0, Q =< E,
	recover_hc_no_adjoin(DownToParse,_,Mid,Q0,Q,R0,R,E0,E,[],Name),
	recover_hc_no_adjoin(    ToParse,Mid,_,R0,R,P0,P,E0,E,[],Target).

recover(lex_head(Word/Q0,ToP),P0,P,E0,E,Target):-
	user:lex(Word,Q0,Q),
	E0 =< Q0, Q =< E,
	recover_hc_no_adjoin(ToP,_,_,Q0,Q,P0,P,E0,E,[],Target).

recover(e_head(Cat,ToP),P0,P,E0,E,Target):-
	hdrug_util:between(E0,E,Q),
	recover_hc(ToP,Cat,_,Q,Q,P0,P,E0,E,[],Target).

recover_hc(ToDo,Cat0,Cat,P0,P,Q0,Q,E0,E,U,T) :-
	user:unify_node(Cat0),
	recover_hc_no_adjoin(ToDo,Cat0,Cat,P0,P,Q0,Q,E0,E,U,T).

% case 1: finished
recover_hc_no_adjoin([],Cat,Cat,P0,P,P0,P,_,_,_,_).

% case 2: go one level up in your own tree
recover_hc_no_adjoin([t(Mid,L,R)|T],_,Goal,QL,QR,P0,P,E0,E,U,Target) :-
	recover_l(L,Q0,QL,E0,Target),
	recover_r(R,QR,Q,E,Target),
	recover_hc(T,Mid,Goal,Q0,Q,P0,P,E0,E,U,Target).

% case 3: adjunction takes place at the current node
recover_hc(ToParse,Small,Goal,QL,QR,P0,P,E0,E,U,Target) :-
	user:address(Small,Add),
	dtree(Target,Add,Name),
	user:aux(Small,Add,_,OwnToParse,Name,R0,R),
	user:check_lex(R0,R,E0,QL,QR,E,U),
	recover_hc_no_adjoin(OwnToParse,_Foot,Mid,QL,QR,QLL,QRR,E0,E,[R0|U],Name),
	recover_hc_no_adjoin(ToParse,Mid,Goal,QLL,QRR,P0,P,E0,E,U,Target).

% recover_l(+RevDs,?Q0,+Q,+LeftExtreme)
recover_l([],Q,Q,_,_).
recover_l([H|T],Q0,Q,E0,Tr):-
	recover(H,Q1,Q,E0,Q,Tr),
	recover_l(T,Q0,Q1,E0,Tr).

% recover_r(+Ds,+Q0,?Q,+RightExtreme)
recover_r([],Q,Q,_,_).
recover_r([H|T],Q0,Q,E,Tr):-
	recover(H,Q0,Q1,Q0,E,Tr),
	recover_r(T,Q1,Q,E,Tr).

%%%%%%%%%%%%%%%
% end of file %
%%%%%%%%%%%%%%%
