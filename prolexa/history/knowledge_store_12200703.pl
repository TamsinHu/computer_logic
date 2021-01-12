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
hyper(cat, 1,[feline,felid]).
hyper(feline, 1,[carnivore]).
hyper(dog, 1,[canine,canid,domesticanimal,domesticatedanimal]).
hyper(kind, 1,[category]).
hyper(bean, 1,[legume]).

% hyponyms
hypo(dog, 1,[puppy,pooch,doggie,doggy,barker,bowwow,cur,mongrel,mutt,lapdog,toydog,toy,huntingdog,workingdog,dalmatian,coachdog,carriagedog,basenji,pug,pugdog,leonberg,newfoundland,newfoundlanddog,greatpyrenees,spitz,griffon,brusselsgriffon,belgiangriffon,corgi,welshcorgi,poodle,poodledog,mexicanhairless]).
hypo(cat, 1,[domesticcat,housecat,felisdomesticus,feliscatus,wildcat]).
hypo(feline, 1,[bigcat,cat,cat,truecat]).
hypo(dog, 1,[basenji,corgi,welshcorgi,cur,mongrel,mutt,dalmatian,coachdog,carriagedog,greatpyrenees,griffon,brusselsgriffon,belgiangriffon,huntingdog,lapdog,leonberg,mexicanhairless,newfoundland,newfoundlanddog,pooch,doggie,doggy,barker,bowwow,poodle,poodledog,pug,pugdog,puppy,spitz,toydog,toy,workingdog]).
hypo(kind, 1,[antitype,artform,brand,make,color,colour,description,flavor,flavour,genre,genus,like,thelike,thelikesof,like,ilk,manner,model,species,stripe,style,type]).
hypo(bean, 1,[commonbean,goabean,soy,soybean,soya,soyabean]).

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
pred(is, 1,[v/is]).
pred(bowow, 1,[n/bowow]).
pred(dog, 1,[n/dog]).
pred(bowwow, 1,[n/bowwow]).
pred(kind, 1,[n/kind]).
pred(bean, 1,[n/bean]).
pred(spill, 1,[v/spill]).


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





