%% quip(+Task, ?QuipName, -Speech)
%  QuipName is a quip with Speech that solves Task.
%  Note: Task argument is optional and defaults to Task=QuipName.

:- external quip/2, quip/3.

quip(QuipName, QuipName, Speech) :-
   quip(QuipName, Speech).

strategy(Task, run_quip(QuipName)) :-
   quip(Task, QuipName, _).
strategy(Task, run_quip(Task)) :-
   quip(Task, _).

normalize_task(run_quip(Quip),
	       begin(monolog(Speech),
		     assert(/quips/spoken/Quip))) :-
   quip(_, Quip, Speech).

