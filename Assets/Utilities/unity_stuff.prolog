%%%
%%% Code for talking to other parts of the C# code
%%%

:- public examination_content/2, pop_up_examination_content/1.

%% examination_content(+Object, -ContentComponent)
%  ContentComponent is the ExaminationContent component of the GameObject Object.
examination_content(Object, ContentComponent) :-
   is_class(Object, $'GameObject'),
   component_of_gameobject_with_type(ContentComponent, Object, $'ExaminationContent').

pop_up_examination_content(ContentComponent) :-
   call_method(ContentComponent, popup, _).

%% emit_grain(+SoundName, +Duration) is det
%  Plays a grain of sound with the specified duration in ms.
emit_grain(Name, Duration) :-
   $this \= $me,
   $this.'EmitGrain'(Name, Duration),
   !.
emit_grain(_,_).

:- public fkey_command/1, fkey_command/2.
:- external fkey_command/2.

%% fkey_command(+FKeySymbol, Documentation)
%  Called by UI whenever a given F-key is pressed.

fkey_command(f1) :-
   generate_overlay("Debug commands",
		    clause(fkey_command(Key, Documentation), _),
		    line(Key, ":\t", Documentation)).
fkey_command(Key) :-
   fkey_command(Key, _).

fkey_command(alt-q, "Quit the game") :-
   call_method($'Application', quit, _).
% These are implemented in the C# code, so the handlers are here
% only to make sure the documentation appears in the help display.
fkey_command(f5, "Pause/unpause game").
fkey_command(f2, "Toggle Prolog window").

:- public display_as_overlay/1.

%% display_as_overlay(+StuffToDisplay)
%  Displays StuffToDisplay on overlay.
display_as_overlay(Stuff) :-
   begin(component_of_gameobject_with_type(Overlay, _, $'DebugOverlay'),
	 call_method(Overlay, updatetext(Stuff), _)).

:- higher_order generate_overlay(0, 1, 0).
generate_overlay(Title, Generator, Template) :-
   all(Template, Generator, Lines),
   display_as_overlay([size(30, line(Title)) | Lines]).

:- higher_order generate_unsorted_overlay(0, 1, 0).
generate_unsorted_overlay(Title, Generator, Template) :-
   findall(Template, Generator, Lines),
   display_as_overlay([size(30, line(Title)) | Lines]).

:- public character_debug_display/2, generate_character_debug_overlay/1.
generate_character_debug_overlay(Character) :-
   property_value(Character, given_name, Name),
   generate_overlay(Name,
		    character_debug_display(Character, Data),
		    Data).