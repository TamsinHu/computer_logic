%%% Definite Clause Grammer for prolexa utterances %%%

utterance(C) --> sentence(C).
utterance(C) --> question(C).
utterance(C) --> command(C).

:- op(600, xfy, '=>').


%%% lexicon, driven by predicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

adjective(_,M)		--> [Adj],    {pred2gr(_P,1,a/Adj, M)}.
noun(s,M)			--> [Noun],   {pred2gr(_P,1,n/Noun,M)}.
noun(p,M)			--> [Noun_p], {pred2gr(_P,1,n/Noun,M),noun_s2p(Noun,Noun_p)}.
iverb(s,M)			--> [Verb_s], {pred2gr(_P,1,v/Verb,M),verb_p2s(Verb,Verb_s)}.
iverb(p,M)			--> [Verb],   {pred2gr(_P,1,v/Verb,M)}.

% hypernyms
hyper(dog, 1,[canine,canid,domestic_animal,domesticated_animal]).

% hyponyms
hypo(dog, 1,[puppy,pooch,doggie,doggy,barker,bowwow,cur,mongrel,mutt,lapdog,toy_dog,toy,hunting_dog,working_dog,dalmatian,coach_dog,carriage_dog,basenji,pug,pug-dog,leonberg,newfoundland,newfoundland_dog,great_pyrenees,spitz,griffon,brussels_griffon,belgian_griffon,corgi,welsh_corgi,poodle,poodle_dog,mexican_hairless]).

% unary predicates for adjectives, nouns and verbs
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
%noun(s,dog) --> [dog].

% most of this follows Simply Logical, Chapter 7

% Original Grammar Rules %%%%%%%%%%%%%%%
sentence1(C) --> determiner(N,M1,M2,C),noun(N,M1),verb_phrase(N,M2).
sentence1([(L:-true)]) --> proper_noun(N,X),verb_phrase(N,X=>L).

verb_phrase(s,M) --> [is],property(s,M).
verb_phrase(p,M) --> [are],property(p,M).
verb_phrase(N,M) --> iverb(N,M).

property(N,M) --> adjective(N,M).
property(s,M) --> [a],noun(s,M).
property(p,M) --> noun(p,M).

determiner(s,X=>B,X=>H,[(H:-B)]) --> [every].
determiner(p,X=>B,X=>H,[(H:-B)]) --> [all].
%determiner(p,X=>B,X=>H,[(H:-B)]) --> [].
%determiner(p, sk=>H1, sk=>H2, [(H1:-true),(H2 :- true)]) -->[some].

proper_noun(s,tweety) --> [tweety].
proper_noun(s,peter) --> [peter].

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

% statement --------------------------- || positive answer (s) ------------------------------ || negative answer --
% - cats are animals ------------------ || - I will remember that a cat is a kind of animal - || - I already know....
% - cats are a kind of animal --------- || - I will remember that a cat is a kind of animal - || - ----------------
% - cats are kinds of animal ---------- || - I will remember that a cat is a kind of animal - || - ----------------
% - cats are an example of an animal -- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is an animal ---------------- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is a kind of animal --------- || - I will remember that a cat is a kind of animal - || - ----------------
% - a cat is an example of an animal -- || - I will remember that a cat is a kind of animal - || - ----------------

% CURRENTLY ONLY CONSIDERING DIRECT HYPER/HYPONYMS COULD WE CONSIDER FULL CHAINS?

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

% new questions
%question1((Q1,Q2)) --> [what],kinds(X1=>Q1,X2=>Q2,C),noun(s,X=>Q1),[do,you,know].
%question1((Q1,Q2)) --> verb_phrase(N,X1),kverb_phrase(N,X1,X2),noun(s,X2).
%question1((Q1,Q2)) --> [is,a],noun(s,X1),kverb_phrase(s,X1=>Q1,X2=>Q2),noun(s,Q2).
%question1(Q) --> [give,me],verb_phrase(s,_X=>Q).
%question1(Q)--> [what],verb_phrase(N,_X=>Q).


% question --------------------------- || positive answer (s) --------- || negative answer -------------------------------
% - what is a cat -------------------- || - a cat is a kind of animal - || - I don't know (what a cat is) ----------------
% - what are cats
% - is a cat a kind of animal -------- || - a cat is a kind of animal - || - I don't know (if a cat is a kind of animal) -
% - are cats a kind of animal
% - are cats kinds of animal
% - what types of animal do you know - || - cats are a kind of animal - || - I don't know any (kinds of animals) ---------
% - what do you know about cats ------ || - cats are a kind of animal - || - I don't know anything about cats ------------
% - tell me about cats --------------- || - cats are a kind of animal - || - I don't know anything about cats ------------
% - tell me what you know about cats ---- || - cats are a kind of animal - || - I don't know anything about cats ------------
% - give me an example of an animal -- || - a cat is a kind of animal - || - I don't know any (kinds of animals) ---------
% - give me some examples of animals - || - cats are the only kind of animal I know - || - I don't know any (kinds of animals) ---------

% - give me an example of each animal you know
% - give me an example of every kind of animal you know
% - tell me everything you know about cats
% - tell me all the animals you know
% - list all the animals you know
% - tell me something about cats
% - do you know anything about cats
% - (can you) tell me about cats

% ADDING INTERMEDIATES
% - what kind of animal is a poodle - a poodle is a kind of dog
% - do you know what kind of animal a poodle is


%%% commands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These DCG rules have the form command(g(Goal,Answer)) --> <sentence>
% The idea is that if :-phrase(command(g(Goal,Answer)),UtteranceList). succeeds,
% it will instantiate Goal; if :-call(Goal). succeeds, it will instantiate Answer.
% See case C. in prolexa.pl
% Example: 
%	command(g(random_fact(Fact),Fact)) --> [tell,me,anything].
% means that "tell me anything" will trigger the goal random_fact(Fact), 
% which will generate a random fact as output for prolexa.

% Original Commands %%%

command(g(retractall(prolexa:stored_rule(_,C)),"I erased it from my memory")) --> forget,sentence(C). 
command(g(retractall(prolexa:stored_rule(_,_)),"I am a blank slate")) --> forgetall. 
command(g(all_rules(Answer),Answer)) --> kbdump. 
command(g(all_answers(PN,Answer),Answer)) --> tellmeabout,proper_noun(s,PN).
command(g(explain_question(Q,_,Answer),Answer)) --> [explain,why],sentence1([(Q:-true)]).
command(g(random_fact(Fact),Fact)) --> getanewfact.
%command(g(pf(A),A)) --> peterflach. 
%command(g(iai(A),A)) --> what. 
command(g(rr(A),A)) --> thanks.

% The special form
%	command(g(true,<response>)) --> <sentence>.
% maps specific input sentences to specific responses.

command(g(true,"I can do a little bit of logical reasoning. You can talk with me about humans and birds.")) --> [what,can,you,do,for,me,minerva].
%command(g(true,"Your middle name is Adriaan")) --> [what,is,my,middle,name].
%command(g(true,"Today you can find out about postgraduate study at the University of Bristol. This presentation is about the Centre for Doctoral Training in Interactive Artificial Intelligence")) --> today.
%command(g(true,"The presenter is the Centre Director, Professor Peter Flach")) --> todaysspeaker.


% New Commands %%%

%command(g(example(X,Answer),Answer)) --> giveme,[X].
command(g(example(X,Answer),Answer)) --> giveme,noun(s, X).
command(g(kinds(X,Answer),Answer)) --> [what,kinds,of],noun(s, X),[do,you,know].


% phrase shortenings %%%

giveme --> [give,me,an,example,of,a].
giveme --> [give,me,an,example,of,an].
giveme --> [give].

hypo --> [hyponym,is,an,example,of,a].

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


%%%% predicates %%%%%%%%%%%%%%

% Original Predicates %%%

rr(A):-random_member(A,["no worries","the pleasure is entirely mine","any time, peter","happy to be of help"]).

random_fact(X):-
	random_member(X,["walruses can weigh up to 1900 kilograms", "There are two species of walrus - Pacific and Atlantic", "Walruses eat molluscs", "Walruses live in herds","Walruses have two large tusks"]).


% New Predicates %%%

example(N,A):-
%pred2gr(_P,1,n/Noun,PN),
%noun(s,N),
phrase(noun(s,N),L),
append([hyponym,is,an,example,of,a],L,X),
%phrase(noun,X),
%(N:-X).
%atomics_to_string([hyponym,is,an,example,of,Z]," " ,A).
atomics_to_string(X," ",A).


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
