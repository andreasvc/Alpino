%% This file is automatically generated from ../src/help.pl

:- module(hdrug_help, [help_listing/0,
		       help/1,
		       help/2,
		       help_add_to_menu/2,
		       help_module/0, help_module/1,
		       help_class/1,  help_class/2,
		       help_key/1,    help_key/2,    help_key/3
		]).

:- expects_dialect(sicstus).

:- meta_predicate hook(:).
:- meta_predicate is_current_predicate(:).

:- use_module(library(charsio), [ format_to_chars/3 ] ).
:- use_module(library(lists), [ member/2 ]).


:- multifile user:help_info/4.

:- discontiguous help_info/4.
:- public help_info/4.

user:help_info(module,help,"The Help System","
The help module provides support to create both on-line and off-line
documentation on Prolog programs. Documentation must be defined by the
hook predicate help_info/4. Documentation on a per module basis is
provided if a help_info(module,Module,TitleString,DescriptionString) 
definition is given for Module. In that case the system also checks
for Module:help_info/4 definitions.  

The module supports production of the help information on standard
output, (which can be converted into html format), and there also 
is an interface to a graphical user interface based on library(tcltk).").

help_info(class,pred,"List of Predicates","
This section lists the predicates defined by the help module.").

help_info(class,hook,"List of Hook Predicates","
This section lists the hook predicates which an application can define 
for the help module.").

help_info(pred,help_listing,"help_listing","Lists all help information.").

help_info(pred,help,"help/help(Module)/help(Module,Class)","
Use help/0 to see for which modules help is available. Use help/1 for
an overview which classes are available for a given module. Use 
help(Module,Class) to see for which keys help is available. "). 

help_info(pred,help_module,"help_module[(M)]",
"Use help_module(M) for a full listing of the help information
available on module M. Without M uses module user.").

help_info(pred,help_class,"help_class(C[,M])",
"Use help_class(C,M) for a full listing of the help information
available for class C in module M. Without M module user is
assumed."). 

help_info(pred,help_key,"help_key(K[,C[,M]])","
Use help_key(K,C,M) for a full listing of the help information
available for key K in class C in module M. If C (and M) are not
given, then use variable for C (and M)."). 

help_info(hook,help_info,"help_info(Class,Key,Usage,Expl)","
Provides help information for Class and Key (both must be
atoms). Usage and Expl are Prolog strings. Typically the Usage string
is a short summary, and Expl is a longer explanation. Class is
typically pred, hook, flag, command, option, etc. Note that each
module can have its own help_info predicates. You can also define
user:help_info/4 declarations on the special class module. In that
case, if a full documentation on a module is requested the Usage
string is used as the title and the Expl string as an introduction to
the module. There can also be Module:help_info/4 declarations on the
special class `class'. If a full listing on a class in Module is
requested, then Usage and Expl are used as the title and introduction
to that section. "). 

non_user_module(M) :-
    a_module(M),
    M \== user.

help_info(pred,help_add_to_menu,"help_add_to_menu(Menu,Interp)","
Interface of the help system and a graphical user interface based on
library(tcltk). Menu must be a menu already existing for Tcl/Tk
interpreter Interp. The various help messages are added as cascaded
menu entries in Menu. Cf. also the help/1 predicate and the
help_info/4 hook predicate."). 

:- public tk_help_info_header/4, tk_help_info_text/4.

tk_help_info_header(Module,Class,K,Text) :-
    help_info(Module,Class,K,TextCodes,_),
    atom_codes(Text,TextCodes).
tk_help_info_text(Module,Class,K,Text) :-
    help_info(Module,Class,K,_,TextCodes),
    atom_codes(Text,TextCodes).


help_add_to_menu(Menu,Interp) :-
    tcltk:tcl_eval(Interp,
		   format('
  proc display_help {module cl k} {
    set w [prolog_var hdrug_help:gen_widget(W) W]
    set text [prolog_var hdrug_help:tk_help_info_text($module,$cl,$k,T) T]
    set header [prolog_var hdrug_help:tk_help_info_header($module,$cl,$k,H) H]
    set title "Help. Module: $module   Class: $cl"
    catch {destroy $w}
    toplevel $w
    wm title $w $title
    frame $w.bot -relief raised -bd 1
    pack $w.bot -side bottom -fill both
    text $w.text -wrap word -relief flat -bd 10 -yscrollcommand "$w.scroll set" -setgrid true -width 80 -height 20
    scrollbar $w.scroll  -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    $w.text tag configure color2 -foreground red
    $w.text insert 0.0 $header color2
    $w.text insert end "\n\n"
    $w.text insert end $text color1
    $w.text configure -state disabled
    button $w.bot.button -command "destroy $w" -text {OK}
    pack $w.bot.button
    }',[]),_),
    findall(Class,a_class(user,Class),Classes),
    help_add_to_menu_ls(Classes,Menu,Interp,user),
    findall(Module,non_user_module(Module),Modules),
    help_add_to_menu_modules(Modules,Menu,Interp).

help_add_to_menu_modules([],_,_).
help_add_to_menu_modules([M|Ms],Menu,Interp):-
    help_add_to_menu_module(M,Menu,Interp),
    help_add_to_menu_modules(Ms,Menu,Interp).

help_add_to_menu_module(Module,Menu,Interp) :-
    tcltk:tcl_eval(Interp,
      format("~w add cascade -label {~w} -menu ~w.module~w",
	    [Menu,Module,Menu,Module]),_),
    tcltk:tcl_eval(Interp,
      format('catch "destroy ~w.module~w"',[Menu,Module]),_), 
    tcltk:tcl_eval(Interp,
      format("menu ~w.module~w",[Menu,Module]),NewMenu0),
    atom_codes(NewMenu,NewMenu0),
    tcltk:tcl_eval(Interp,
      format("~w add command -label Introduction -command {display_help user module {~q}}",[NewMenu,Module]),_),
    findall(Class,a_class(Module,Class),Classes),
    help_add_to_menu_ls(Classes,NewMenu,Interp,Module).

help_add_to_menu_ls([],_Menu,_Interp,_Module).
help_add_to_menu_ls([Class|Classes],Menu,Interp,Module) :-
    help_add_to_menu_l(Class,Menu,Interp,Module),
    help_add_to_menu_ls(Classes,Menu,Interp,Module).

help_add_to_menu_l(Class,Menu,Interp,Module) :-
    tcltk:tcl_eval(Interp,
      format("~w add cascade -label {Help on ~w} -menu ~w.~w",
	     [Menu,Class,Menu,Class]),_),
    tcltk:tcl_eval(Interp,
      format('catch "destroy ~w.~w"',[Menu,Class]),_), 
    tcltk:tcl_eval(Interp,
      format("menu ~w.~w",[Menu,Class]),NewMenu0),
    atom_codes(NewMenu,NewMenu0),
    tcltk:tcl_eval(Interp,
      format("~w add command -label Introduction -command {display_help user class {~q}}",[NewMenu,Class]),_),
    findall(Key,help_info(Module,Class,Key,_,_),Keys0),
    %sort(Keys0,Keys),
    Keys0=Keys,
    help_add_to_menu_l_ls(Keys,Class,NewMenu,Interp,Module).

help_add_to_menu_l_ls([],_,_,_,_).
help_add_to_menu_l_ls([Key|Keys],Class,NewMenu,Interp,Module):-
    %% update is required, since otherwise winfo height doesn't work
    tcltk:tcl_eval(Interp,format("update",[]),_),
    tcltk:tcl_eval(Interp,format("winfo reqheight ~w",[NewMenu]),ReqHeight0),
    tcltk:tcl_eval(Interp,format("winfo screenheight ~w",[NewMenu]),Height0),
    number_codes(ReqHeight,ReqHeight0),
    number_codes(Height,Height0),
    (	ReqHeight > Height-50
    ->  tcltk:tcl_eval(Interp,format("
           ~w add cascade -label More -menu ~w.more
           menu ~w.more
           ",[NewMenu,NewMenu,NewMenu]),Menu0),
	atom_codes(Menu,Menu0),
	help_add_to_menu_l_ls([Key|Keys],Class,Menu,Interp,Module)
    ;  tcltk:tcl_eval(Interp,
	format("~w add command -label {~w} -command {display_help {~q} {~q} {~q} }",
	       [NewMenu,Key,Module,Class,Key]),_),
       help_add_to_menu_l_ls(Keys,Class,NewMenu,Interp,Module)
    ).

:- public gen_widget/1.

gen_widget(Symbol):-
    Prefix='.dt',
    (	bb_get(Prefix,Integer)
    ->  true
    ;   Integer=0
    ),
    Next is Integer+1,
    bb_put(Prefix,Next),
    charsio:format_to_chars('~w~w',[Prefix,Integer],SymbolChars),
    atom_codes(Symbol,SymbolChars).





:- multifile user:user_help/0.
user:user_help :-
    findall(M,a_module(M),Modules),
    format(user_error,"Help is available on the modules ~w~n",[Modules]),
    format(user_error,"Use help(Module) help(Module,Class) to get an overview~n",[]),
    format(user_error,"on what help is available. Use help_module(Module)~n",[]),
    format(user_error,"help_class(Class,Module) and help_key(Key,Class,Module)~n",[]),
    format(user_error,"for an actual listing of the corresponding help information~n",[]),
    format(user_error,"Finally, help_listing/0 is used to get all help information~n",[]).

help(Module) :-
    a_module(Module),
    user:help_info(module,Module,Title,Intro),
    format("~w: ~s~n~n~s~n~n",[Module,Title,Intro]),
    findall(C,a_class(Module,C),Classes),
    format("Help in module ~w is available on classes:~n~w~n",
	   [Module,Classes]).

help(Module,Class) :-
    a_module(Module),
    a_class(Module,Class),
    help_info(Module,class,Class,Title,Intro),
    format("~s~n~n~s~n~n",[Title,Intro]),
    findall(K,a_key(Module,Class,K),Keys),
    format("Help in module ~w, class ~w is available for keys:~n~w~n",
	   [Module,Class,Keys]).

help_listing :-
    findall(M,non_user_module(M),Modules),
    help_user_module(Next),
    help_modules(Modules,Next).

help_modules([],_).
help_modules([M|Ms],N0):-
    help_module(M,N0),
    N1 is N0+1,
    help_modules(Ms,N1).

help_module :-
    help_module(user,1).
help_module(Module) :-
    a_module(Module),
    help_module(Module,1).
help_module(Module,Section) :-
    user:help_info(module,Module,Title,Intro),
    format("~w. ~w: ~s~n~n~s~n~n",[Section,Module,Title,Intro]),
    findall(Class,a_class(Module,Class),Classes),
    help_classes(Classes,Module,Section,1).

help_classes([],_,_,_N).
help_classes([Class|Classes],Module,Section,N0) :-
    help_class(Class,Module,Section,N0),
    N1 is N0+1,
    help_classes(Classes,Module,Section,N1).

help_class(Class) :-
    help_class(Class,user,1,1).
help_class(Class,Module) :-
    a_module(Module),
    help_class(Class,Module,1,1).
help_class(Class,Module,Section,N0) :-
    help_info(Module,class,Class,Title,Intro),
    format("~n~n~w.~w. ~s~n~n~s~n~n",[Section,N0,Title,Intro]),
    findall(Key,help_info(Module,Class,Key,_,_),Keys0),
%%    sort(Keys0,Keys),
    Keys0=Keys,
    help_keys(Keys,Class,Module,Section,N0,1).

help_keys([],_Class,_Module,_S,_Su,_N).
help_keys([Key|Keys],Class,Module,Na,Nb,N0) :-
    help_key(Key,Class,Module,Na,Nb,N0),
    N1 is N0+1,
    help_keys(Keys,Class,Module,Na,Nb,N1).

help_key(Key):-
    help_key(Key,_,_).
help_key(Key,Class) :-
    help_key(Key,Class,_).
help_key(Key,Class,Module) :-
    a_module(Module),
%    help_key(Key,Class,Module,1,1,1).
    help_info(Module,Class,Key,Title,Expl),
    format("~nModule: ~w~n",[Module]),
    format("Class:  ~w~n",[Class]),
    format("~s~n~n~s~n~n",[Title,Expl]).

help_key(Key,Class,Module,Na,Nb,N0) :-
    help_info(Module,Class,Key,Title,Expl),
    format("~n~n~w.~w.~w. ~s~n~n~s~n~n",[Na,Nb,N0,Title,Expl]).

a_module(Module) :-
    findall(Mod,(user:help_info(module,Mod,_,_),Mod\==user),Modules0),
    sort(Modules0,Modules),
    member(Module,[user|Modules]).

a_class(Module,Class) :-
    findall(Class,(help_info(Module,Class,_,_,_),
		   Class\==module,
		   Class\==class),
		   Classes0),
    sort(Classes0,Classes),
    member(Class,Classes).

a_key(Module,Class,Key) :-
    findall(K,help_info(Module,Class,K,_,_),Keys0),
    %%sort(Keys0,Keys),
    Keys0=Keys,
    member(Key,Keys).

%% only called from help_listing.
help_user_module(Next) :-
    user:help_info(module,user,Title,Intro),
    format("~w. ~s~n~n~s~n~n",[1,Title,Intro]),
    findall(Class,a_class(user,Class),Classes),
    help_user_classes(Classes,2,Next).


help_user_classes([],N,N).
help_user_classes([Class|Classes],N0,N) :-
    help_user_class(Class,N0),
    N1 is N0+1,
    help_user_classes(Classes,N1,N).

help_user_class(Class,N0) :-
    user:help_info(class,Class,Title,Intro),
    format("~n~n~w. ~s~n~n~s~n~n",[N0,Title,Intro]),
    findall(Key,user:help_info(Class,Key,_,_),Keys0),
    %%sort(Keys0,Keys),
    Keys0=Keys,
    help_user_keys(Keys,Class,N0,1).

help_user_keys([],_Class,_Su,_N).
help_user_keys([Key|Keys],Class,Nb,N0) :-
    help_user_key(Key,Class,Nb,N0),
    N1 is N0+1,
    help_user_keys(Keys,Class,Nb,N1).

help_user_key(Key,Class,Nb,N0) :-
    user:help_info(Class,Key,Title,Expl),
    format("~n~n~w.~w. ~s~n~n~s~n~n",[Nb,N0,Title,Expl]).


help_info(Module,Class,Key,Title,Expl) :-
    hook(Module:help_info(Class,Key,Title,Expl)).

%% from hdrug_util
hook(Module:Call) :-
    is_current_predicate(Module:Call),
    Module:Call.

is_current_predicate(Module:Call) :-
    (	current_predicate(_,Module:Call)
    ->  true
    ;	predicate_property(Module:Call,imported_from(NewModule)),
	is_current_predicate(NewModule:Call)
    ).
