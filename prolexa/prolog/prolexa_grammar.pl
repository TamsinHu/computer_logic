%%% Definite Clause Grammer for prolexa utterances %%%

utterance(C) --> sentence(C).
utterance(C) --> question(C).
utterance(C) --> command(C).

:- op(600, xfy, '=>').


%%% lexicon, driven by predicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
adjective(_,M)		--> [Adj],    {pred2gr(_P,1,a/Adj, M)}.
noun(s,M)		--> [Noun],   {pred2gr(_P,1,n/Noun,M)}.
noun(p,M)		--> [Noun_p], {pred2gr(_P,1,n/Noun,M),noun_s2p(Noun,Noun_p)}.
iverb(s,M)			--> [Verb_s], {pred2gr(_P,1,v/Verb,M),verb_p2s(Verb,Verb_s)}.
iverb(p,M)			--> [Verb],   {pred2gr(_P,1,v/Verb,M)}.

hypernym(M2,M1)     --> [Noun],   {hyper2gr(_P,1,Noun,M1,M2)}.
hypernym(M2,M1)     --> [Noun_p], {hyper2gr(_P,1,Noun,M1,M2),noun_s2p(Noun,Noun_p)}.
hyponym(M1,M2)     --> [Noun],   {hypo2gr(_P,1,Noun,M1,M2)}.
hyponym(M1,M2)     --> [Noun_p], {hypo2gr(_P,1,Noun,M1,M2),noun_s2p(Noun,Noun_p)}.


% hypernyms
hyper(dog, 1,[canine,canid,domesticanimal,domesticatedanimal]).

% hyponyms
hypo(dog, 1,[puppy,pooch,doggie,doggy,barker,bowwow,cur,mongrel,mutt,lapdog,toydog,toy,huntingdog,workingdog,dalmatian,coachdog,carriagedog,basenji,pug,pugdog,leonberg,newfoundland,newfoundlanddog,greatpyrenees,spitz,griffon,brusselsgriffon,belgiangriffon,corgi,welshcorgi,poodle,poodledog,mexicanhairless]).

% unary predicates for adjectives, nouns and verbs
pred(dog,     1,[n/dog]).
pred(canine,  1,[n/canine]).
pred(cat,     1,[n/cat]).
pred(feline,  1,[n/feline]).
pred(human,   1,[a/human,n/human]).
pred(mortal,  1,[a/mortal,n/mortal]).
pred(man,     1,[a/male,n/man]).
pred(woman,   1,[a/female,n/woman]).
pred(married, 1,[a/married]).
pred(bachelor,1,[n/bachelor]).
pred(mammal,  1,[n/mammal]).
pred(bird,    1,[n/bird]).
pred(bat,     1,[n/bat]).
pred(penguin, 1,[n/penguin]).
pred(sparrow, 1,[n/sparrow]).
pred(fly,     1,[v/fly]).


pred2gr(P,1,C/W,X=>Lit):-
	pred(P,1,L),
	member(C/W,L),
	Lit=..[P,X].

hyper2gr(P,1,W,X=>Lit,Y=>Lit2):-
	hyper(P,1,L),
	member(W,L),
	Lit=..[P,X],
	Lit2=..[W,Y].

hypo2gr(P,1,W,X=>Lit,Y=>Lit2):-
	hypo(P,1,L),
	member(W,L),
	Lit=..[W,X],
    Lit2=..[P,Y].

noun_s2p(Noun_s,Noun_p):-
	( Noun_s=woman -> Noun_p=women
	; Noun_s=man -> Noun_p=men
	; atom_concat(Noun_s,s,Noun_p)
	).

verb_p2s(Verb_p,Verb_s):-
	( Verb_p=fly -> Verb_s=flies
	; 	atom_concat(Verb_p,s,Verb_s)
	).

%%% sentences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sentence(C) --> sword,sentence1(C).

sword --> [].
sword --> [that].

% most of this follows Simply Logical, Chapter 7

% Original Grammar Rules %%%%%%%%%%%%%%%
sentence1(C) --> determiner(N,M1,M2,C),noun(N,M1),verb_phrase(N,M2).
sentence1([(L:-true)]) --> proper_noun(N,X),verb_phrase(N,X=>L).
sentence1([(L:-true)]) --> a,noun(s,M1),is(s),kinds(M2=>M1=>L),hypernym(M2,M1).
sentence1([(L:-true)]) --> noun(p,M1),is(p),kinds(M2=>M1=>L),hypernym(M2,M1).
sentence1([(L:-true)]) --> a,hyponym(M1,M2),is(s),kinds(M1=>M2=>L),noun(s,M2).
sentence1([(L:-true)]) --> hyponym(M1,M2),is(p),kinds(M1=>M2=>L),noun(p,M2).

kinds(X=>Y=>isa(X,Y)) --> a,kind.
kinds(X=>Y=>isa(X,Y)) --> [].
kinds(X=>Y=>isa(X,Y)) --> kinds.

is(s) --> [is].
is(s) --> [is],a.
is(p) --> [are].

verb_phrase(s,M) --> [is],property(s,M).
verb_phrase(p,M) --> [are],property(p,M).
verb_phrase(N,M) --> iverb(N,M).

property(N,M) --> adjective(N,M).
property(s,M) --> [a],noun(s,M).
property(p,M) --> noun(p,M).

determiner(s,X=>B,X=>H,[(H:-B)]) --> [every].
determiner(p,X=>B,X=>H,[(H:-B)]) --> [all].
%determiner(p,X=>B,X=>H,[(H:-B)]) --> [].
%determiner(p,sk=>H1,sk=>H2,[(H1:-true),(H2:-true)]) --> [some].

proper_noun(s,tweety) --> [tweety].
proper_noun(s,peter) --> [peter].


%%% questions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
question(Q) --> qword,question1(Q).

qword --> [].
%qword --> [if]. 
%qword --> [whether].

% (plural answers in the form of comma separated lists with an 'and' before the last element)

% original questions
question1(Q) --> [who],verb_phrase(s,_X=>Q).
question1(Q) --> [is],proper_noun(N,X),property(N,X=>Q).
question1(Q) --> [does],proper_noun(_,X),verb_phrase(_,X=>Q).
%question1((Q1,Q2)) --> [are,some],noun(p,sk=>Q1),property(p,sk=>Q2).

% is a cat a feline
% is a cat a kind of feline
% is a cat a type of feline
% is a cat an example of a feline
% are cats feline
% are cats felines
% are cats a kind of feline
% are cats a type of feline
% are cats kinds of felines
% are cats examples of felines
question1(Q) --> is(N),noun(N,M1),kinds(M2=>M1=>Q),noun(_,M2).

% what cats do you know
% what kinds of cat do you know
question1(Q) --> [what],kinds(M2=>M1=>Q),hypernym(M2,M1),[do,you,know].

% what do you know about cats
% tell me about cats
% tell me something about cats
% tell me anything about cats
% tell me what you know about cats
% can you tell me about cats
% will you tell me about cats
question1(Q) --> tell,kinds(M2=>M1=>Q),hyponym(M2,M1).
question1(Q) --> tell,kinds(M2=>M1=>Q),hypernym(M2,M1).

% what is a cat
% what are cats
question1(Q) --> [what],is(_),kinds(M1=>M2=>Q),hyponym(M1,M2).

% give me cats
% give me an example of a cat
% give me a type of cat
question1(Q) --> give,kinds(M1=>M2=>Q),hypernym(M1,M2).


%%% commands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These DCG rules have the form command(g(Goal,Answer)) --> <sentence>
% The idea is that if :-phrase(command(g(Goal,Answer)),UtteranceList). succeeds,
% it will instantiate Goal; if :-call(Goal). succeeds, it will instantiate Answer.
% See case C. in prolexa.pl
% Example: 
%	command(g(random_fact(Fact),Fact)) --> [tell,me,anything].
% means that "tell me anything" will trigger the goal random_fact(Fact), 
% which will generate a random fact as output for prolexa.

command(g(retractall(prolexa:stored_rule(_,C)),"I erased it from my memory")) --> forget,sentence(C).
command(g(retractall(prolexa:stored_rule(_,_)),"I am a blank slate")) --> forgetall. 
command(g(all_rules(Answer),Answer)) --> kbdump. 
command(g(all_answers(PN,Answer),Answer)) --> tellmeabout,proper_noun(s,PN).
command(g(all_answers(N,Answer),Answer)) --> tellmeabout,noun(s,N).
command(g(explain_question(Q,_,Answer),Answer)) --> [explain,why],sentence1([(Q:-true)]).
command(g(random_fact(Fact),Fact)) --> getanewfact.
command(g(rr(A),A)) --> thanks.

% The special form
%	command(g(true,<response>)) --> <sentence>.
% maps specific input sentences to specific responses.

command(g(true,"I can do a little bit of logical reasoning. You can talk with me about humans and birds.")) --> [what,can,you,do,for,me,hyprolexa].
command(g(true,"Yes, you are a genius.")) --> [am,i,a,genius].


%%% phrase shortenings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
can --> [can].
can --> [will,not].
can --> [will].
can --> [wont].

tell --> [do,you,know],about.
tell --> [i,want,to,know,about].
tell --> [what,do,you,know,about].
tell --> [tell,me],about.
tell --> [tell,me,what,you,know],about.
tell --> can,[you,tell,me],about.
tell --> can,[you,tell,me,what,you,know],about.

about --> [something,about].
about --> [anything,about].
about --> [about].

give --> [give,me].

kind --> [kind,of].
kind --> [type,of].
kind --> [].
kind --> [example,of],a.
kinds --> [kinds,of].
kinds --> [types,of].
kinds --> [examples,of].

thanks --> [thank,you].
thanks --> [thanks].
thanks --> [great,thanks].

getanewfact --> getanewfact1.
getanewfact --> [tell,me],getanewfact1.

getanewfact1 --> [anything].
getanewfact1 --> [a,random,fact].
getanewfact1 --> [something,i,'don\'t',know].

kbdump --> [spill,the,beans].
kbdump --> [tell,me],allyouknow.

forget --> [forget].

forgetall --> [forget],allyouknow.

allyouknow --> all.
allyouknow --> all,[you,know].

all --> [all].
all --> [everything].

tellmeabout --> [tell,me,about].
tellmeabout --> [who,is].
tellmeabout --> [tell,me],all,[about].

a --> [a].
a --> [an].


%%%% predicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rr(A):-random_member(A,["no worries","the pleasure is entirely mine","any time, peter","happy to be of help"]).

random_fact(X):-
	random_member(X,["walruses can weigh up to 1900 kilograms", "There are two species of walrus - Pacific and Atlantic", "Walruses eat molluscs", "Walruses live in herds","Walruses have two large tusks"]).







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% BELOW HERE IS DETRITIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%write_debug('hereiam'),
	%write_debug(P),
	%write_debug(X),
	%write_debug(Lit).

%hyper2gr(P,1,W,X=>Lit):-
%	hyper(P,1,L),
%	member(W,L),
%	Lit=..[P,X].

%


%hypo2gr(P,1,W,X=>Lit):-
%	hypo(P,1,L),
%	member(W,L),
%	Lit=..[P,X].

%hypernym(s,noun(s,feline),noun(s,cat)) --> [cat].
%hypernym(s,(X,feline(X)),(Y,cat(Y))) --> [cat].

%hypernym(s,M)     --> [Noun],   {hyper2gr(_P,1,Noun,M)}.
%hyponym(s,M)           --> [Noun],   {hypo2gr(_P,1,Noun,M)}.


%noun(s,M,_)    --> [Noun],   {pred2gr(_P,1,n/Noun,M)}.

%sentence1([(L:-true)]) --> a,noun(s,X),[is],a,kind,hypernym(s,X=>L).
%sentence1([(L:-true)]) --> a,noun(s,X=>L),[is],a,example,hypernym(s,X).
%sentence1([(L:-true)]) --> a,hyponym(s,X),[is],a,kind,noun(s,X=>L).
%trial
%sentence1([(L:-true)]) --> a,noun(s,X=>L),[is],a,kind,hypernym(s,X1,X=>L).

%sentence1([(L:-true)]) --> a,noun(N,Xn),kverb_phrase(N,Xn,Xn=>L).
%%sentence1([(L:-true)]) --> a,hyponym(N,X),kverb_phraseo(N,X=>L).
%kverb_phrase(N,Xn,Y) --> transitive_verb(X=>Y),hypernym(N,Xn,X).
%%kverb_phraseo(N,M) --> transitive_verb(Y=>M),noun(N,Y).
%%transitive_verbr(Y=>X=>isa(X,Y)) --> [is],a,kind.
%transitive_verb(Y=>X=>isa(X,Y)) --> [is],a,kind.


%sentence1([(L:-true)]) --> a,noun(N,X),kverb_phrase(N,Xn,Xn=>L).
%%sentence1([(L:-true)]) --> a,hyponym(N,X),kverb_phraseo(N,X=>L).
%kverb_phrase(N,Xn,Y) --> transitive_verb(X=>Y),hypernym(N,Xn,X).
%%kverb_phraseo(N,M) --> transitive_verb(Y=>M),noun(N,Y).
%%transitive_verbr(Y=>X=>isa(X,Y)) --> [is],a,kind.
%transitive_verb(Y=>X=>isa(X,Y)) --> [is],a,kind.



%sentence1([(hypernym(s,M2,M1):-true)]) --> a,noun(s,M1),[is],a,kind,hypernym(s,M2,M1).
%sentence1([(L:-true)]) --> a,noun(N,M1),[is],kverb_phrase(N,M2=>M1=>L),hypernym(s,M2,M1).

%sentence1([(L:-true)]) --> a,noun(N,M1),[is],kverb_phrase(N,M2=>M1=>L),hypernym(s,M2,M1).
%sentence1([(L:-true)]) --> a,noun(N,M1),[is],kverb_phrase(N,M2=>M1=>L),hypernym(s,M2,M1).
%hypernym(s,M2,M1) --> hypernym(s,M3,M4).

%sentence1([(L:-true)]) --> a,noun(N,X),verb_phrase(N,Y=>L).

%sentence1([(M1=M3):-true]) --> a,noun(s,M1),[is],a,kind,hypernym(s,M2,M3).
%sentence1([(hypernym(s,M2,M1):-true)]) --> a,noun(s,M1),[is],a,kind,hypernym(s,M2,M3).
%sentence1([(isa(M1,M2):-true)]) --> a,noun(s,M1),verb_phrase(s,M2).
%sentence1([((M1=>M2):-true)]) --> a,noun(s,M1),[is],a,kind,hypernym(s,M2,M1).
%sentence1([(L:-true)]) --> a,noun(s,M),verb_phrase(s,M=>L).
%sentence1([(L:-true)]) --> a,noun(N,X1),[is],a,kind,noun(N,X2=>L).


% new questions
%question1(Q) --> [is],a,noun(s,X=>Q),a,hypernym(s,X).
%question1(Q) --> [what,kinds,of],hypernym(s,_X=>Q),[do,you,know].
%question1(Q) --> [give,me,an,example,of],a,hypernym(s,_X=>Q).
%question1(Q) --> [what,is],a,noun(s,_X=>Q).

% trial questions
%question1(isa(Q1,Q2)) --> [is],a,noun(s,Q1),property(s,Q2).
%question1(isa(Q1,Q2)) --> [is],a,noun(s,Q1),a,hypernym(s,Q2,Q1).
%question1((hypernym(s,M2,M1))) --> [is],a,noun(s,M1),a,hypernym(s,M2,M1).

%question1((hypernym(s,M2,M1))) --> [is],a,noun(s,M1),a,kind,noun(s,M2).

%question1(Q) --> [is],kverb_phrase(s,X=>Q),a,kind,noun(s,X).
%question1(Q) --> kverb_phrase(s,X=>Q),a,kind,noun(s,X). % question has to be wrong way for answer correct
%question1(Q) --> [is],a,noun(s,X),a,kind,noun(s,X=>Q).

%question1(Q) --> [is],a,noun(s,M1=>Q),a,kind,noun(s,M2).
%question1((Q1,Q2)) --> [is],a,noun(s,M1=>Q1),a,hypernym(s,M2=>Q2,M1).
%question1(Q) --> [is],a,noun(N,X1),property(N,X2=>Q).
%question1(Q) --> [is],a,noun(s,X=>Q),a,hypernym(s,Q).
%question1(Q) --> [is],a,noun(s,X1=>Q),a,noun(s,X2=>Q).

%command(g(pf(A),A)) --> peterflach.
%command(g(iai(A),A)) --> what.
%command(g(true,"Your middle name is Adriaan")) --> [what,is,my,middle,name].
%command(g(true,"Today you can find out about postgraduate study at the University of Bristol. This presentation is about the Centre for Doctoral Training in Interactive Artificial Intelligence")) --> today.
%command(g(true,"The presenter is the Centre Director, Professor Peter Flach")) --> todaysspeaker.

%%% various stuff for specfic events

% today --> [what,today,is,about].
% today --> [what,is,today,about].
% today --> [what,is,happening,today].
% 
% todaysspeaker --> [who,gives,'today\'s',seminar].
% todaysspeaker --> [who,gives,it].
% todaysspeaker --> [who,is,the,speaker].
% 
% peterflach --> [who,is],hepf.
% peterflach --> [tell,me,more,about],hepf.
% 
% what --> [what,is],iai.
% what --> [tell,me,more,about],iai.
% 
% hepf --> [he].
% hepf --> [peter,flach].
% 
% iai --> [that].
% iai --> [interactive,'A.I.'].
% iai --> [interactive,artificial,intelligence].
% 
% pf("According to Wikipedia, Pieter Adriaan Flach is a Dutch computer scientist and a Professor of Artificial Intelligence in the Department of Computer Science at the University of Bristol.").
% 
% iai("The Centre for Doctoral Training in Interactive Artificial Intelligence will train the next generation of innovators in human-in-the-loop AI systems, enabling them to responsibly solve societally important problems. You can ask Peter for more information.").
%

%verb_phrase(N,M) --> transitive_verb(Y=>M),proper_noun(N,Y).
%transitive_verb(Y=>X=>likes(X,Y)) --> [likes].


%hypernym(s,Noun,M)     --> [Noun],   {hyper2gr(_P,1,Noun,M)}.
%hypernym(s,hypernym(s,M2,M1),M3) --> [Noun],   {hyper2gr(_P,1,Noun,M2,M3)}.


%sentence1([(L:-true)]) --> a,noun(s,X),[is],a,hypernym(s,X=>L).
%sentence1([(L:-true)]) --> a,hyponym(s,X),[is],a,noun(s,X=>L).

%sentence1([(L:-true)]) --> [a],noun(s,X),[is,a],hypernym(s,X=>L).
%sentence1([(hypernym(s,M):-true)])--> [a],noun(s,M),[is,a],hypernym(s,M).
%sentence1(C) --> [a],noun(s,M),[is,a],hypernym(s,M).
%sentence1(_C) --> [a],hyponym(s,M),[is,a],noun(s,M).

% property(s,M) --> [a],hypernym(s,M).

%[a, dog, is, a, kind, of, canine]
%[a, dog, is, a, canine]
%noun(s,dog) --> [dog].
%hypernym(s,dog) --> [canine].

%hypernym(s,dog) --> [canine, domesticated_animal].
%hypernym(s,dog) --> [domesticated_animal].

%[every,dog,is,a,animal]


% New Predicates %%%
%
%example(N,A):-
%%pred2gr(_P,1,n/Noun,PN),
%%noun(s,N),
%phrase(noun(s,N),L),
%append([hyponym,is,an,example,of,a],L,X),
%%phrase(noun,X),
%%(N:-X).
%%atomics_to_string([hyponym,is,an,example,of,Z]," " ,A).
%atomics_to_string(X," ",A).

%giveme --> [give,me,an,example,of,a].
%giveme --> [give,me,an,example,of,an].
%giveme --> [give].

%hypo --> [hyponym,is,an,example,of,a].

%command(g(example(X,Answer),Answer)) --> giveme,[X].
%command(g(example(X,Answer),Answer)) --> giveme,noun(s, X).
%command(g(kinds(X,Answer),Answer)) --> [what,kinds,of],noun(s, X),[do,you,know].

%hyper(s,M)          --> [Noun],   {hyper2gr(_P,1,Noun,M)}.
%hyper(dog, 1,[canine,canid,domestic_animal,domesticated_animal]).
%{hyper2gr(_P,1,Noun,M)}.

%hypernym(s,X):-[X].
%[X]:-hyponym(s,X).

%noun(s,dog) --> [dog].




%question1(Q) --> [is],property(s,X),property(s,X=>Q).
%question1((Q1,Q2)) --> [is],property(N,X),property(N,X=>Q).
%question1((Q1,Q2)) --> [what],kinds(X1=>Q1,X2=>Q2,C),noun(s,X=>Q1),[do,you,know].
%question1((Q1,Q2)) --> verb_phrase(N,X1),kverb_phrase(N,X1,X2),noun(s,X2).
%question1((Q1,Q2)) --> [is,a],noun(s,X1),kverb_phrase(s,X1=>Q1,X2=>Q2),noun(s,Q2).
%question1(Q) --> [give,me],verb_phrase(s,_X=>Q).
%question1(Q)--> [what],verb_phrase(N,_X=>Q).

% New Grammar Rules %%%%%%%%%%%%%%
%sentence1(C) --> hyponym,verb_phrase(N,M).
%sentence1(C) --> property(N,M1), kind(N,M2).
%sentence1(C) --> property(N,M1), kverb_phrase(N,M2).
%sentence1(C) --> property(s,M1), kind(M1,M2,C), noun(s,M2).
%sentence1(C) --> property(N,M1), verb_phrase(N,M1,M2,C), noun(s,M2).

%hyponym --> [hyponym,is].

%verb_phrase(s,M1,M2,C) --> [is],kind(M1,M2,C).
%verb_phrase(p,M1,M2,C) --> [are],kind(M1,M2,C).
%verb_phrase(p,M1,M2,C) --> [are],kinds(M1,M2,C).
%kverb_phrase(p,M) --> [are],kind(p,M).
%kverb_phrase(s,M) --> [is],kind(s,M).
%kverb_phrase(p,M) --> [are],kind(p,M).
%verb_phrase(s,M) --> [an,example,of],property(s,M).

%kind(s,M) --> [is,a,kind,of],noun(s,M).
%kind(s,M) --> [are kinds of],noun(p,M).

%kind(X1=>B,X2=>H,[(H:-B)]) --> [a,kind,of].
%kinds(X1=>B,X2=>H,[(H:-B)]) --> [kinds,of].

%kind(s,M) --> [a,kind,of],noun(s,M).
%kind(p,M) --> [kinds,of],noun(p,M).

%hypernym(s,M2,M1)     --> [Noun],   {hyper2gr(_P,1,Noun,M1,M2)}.
%hypernym(p,M2,M1)     --> [Noun_p], {hyper2gr(_P,1,Noun,M1,M2),noun_s2p(Noun,Noun_p)}.

%hypernym(M2,M1) --> hyponym(M1,M2).
%hyponym(M1,M2) --> hypernym(M2,M1).

% new


% statement --------------------------- || positive answer (s) ------------------------------ || negative answer --
% - cats are animals ------------------ || - I will remember that a cat is a kind of animal - || - I already know....
% - cats are a kind of animal --------- || - I will remember that a cat is a kind of animal - || - ----------------
% - cats are kinds of animal ---------- || - I will remember that a cat is a kind of animal - || - ----------------
% - cats are an example of an animal -- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is an animal ---------------- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is a kind of animal --------- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is an example of an animal -- || - I will remember that a cat is a kind of animal - || - ----------------

% CURRENTLY ONLY CONSIDERING DIRECT HYPER/HYPONYMS COULD WE CONSIDER FULL CHAINS?



%hyponym(s,M1,M2)      --> [Noun],   {hypo2gr(_P,1,Noun,M1,M2)}.
%hyponym(p,M1,M2)      --> [Noun_p], {hypo2gr(_P,1,Noun,M1,M2),noun_s2p(Noun,Noun_p)}.

% new
%
%sentence1([(hypernym(M2,M1):-true)]) --> a,noun(s,M1),is(s),kind,hypernym(M2,M1).
%sentence1([(hypernym(M2,M1):-true)]) --> noun(p,M1),is(p),kind,hypernym(M2,M1).
%sentence1([(hyponym(M1,M2):-true)]) --> a,hyponym(M1,M2),is(s),noun(s,M2).
%sentence1([(hyponym(M1,M2):-true)]) --> hyponym(M1,M2),is(p),noun(p,M2).

