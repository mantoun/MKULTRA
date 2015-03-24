%%
%% Driver code
%% This is the code that talks to action_selection.prolog
%%

%% poll_tasks
%  Polls all tasks of all concerns.
poll_tasks :-
   begin(bind_default_task_indexicals,
	 forall(concern(Task, task),
		once(poll_task(Task)))).

%% poll_task(+Task)
%  Attempts to make forward progress on Task's current step.
poll_task(T) :-
   T/monitor/Condition:Continuation,
   Condition,
   !,
   within_task(T, invoke_continuation(Continuation)).
poll_task(T) :-
   (T/current:A)>>ActionNode,
   !,
   ((ActionNode:action) ->
      poll_action(T, A)
      ;
      poll_builtin(T, A)).

poll_action(T, A) :-
   % Make sure it's still runnable
   runnable(A) ; interrupt_step(T, achieve(runnable(A))).

poll_builtin(T, wait_condition(Condition)) :-
   !,
   (Condition -> step_completed(T) ; true).
poll_builtin(_, wait_event(_)).   % nothing to do.
poll_builtin(T, wait_event(_, Timeout)) :-
   ($now > Timeout) ->
       step_completed(T) ; true.

bind_default_task_indexicals :-
   default_addressee(A),
   bind(addressee, A).
   
%%
%%  Interface to mundane action selection
%%

propose_action(A, task, T) :-
   T/current:A:action.

score_action(A, task, T, Score) :-
   T/current:X:action,
   A=X,
   T/priority:Score.

on_event(E, task, T, wait_event_completed(T, E)) :-
   task_waiting_for(T, E).

task_waiting_for(T, E) :-
   T/current:X,
   (X=E ; X=wait_event(E) ; X=wait_event(E,_)).

wait_event_completed(T, E) :-
   % Check to make sure that we're still waiting for this event.
   task_waiting_for(T, E),
   bind_default_task_indexicals,
   step_completed(T).
wait_event_completed(_,_).

%%
%% Debug display
%%

character_debug_display(Character, line("Task:\t", Task, "\t", Status, "\t", Current)) :-
   Character::(concern(T, task),
	       T/type:task:Task,
	       (concern_status(T, Status) -> true ; (Status=null)),
	       T/current:Current).