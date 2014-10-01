:- public truth_value/2, admitted_truth_value/3.
:- external know_whether/1, pretend_truth_value/3.

truth_value(P, Value) :-
   P ->
     Value=true
     ;
     (know_whether(P) ->
         Value = false
         ;
         Value = unknown).

:- external pretend_truth_value/3.

admitted_truth_value(Listener, P, Value) :-
   pretend_truth_value(Listener, P, Value),
   !.
admitted_truth_value(_, P, Value) :-
   truth_value(P, Value).
