
# Hyprolexa #
<!--This repository contains Prolog code for a simple question-answering assistant.
The top-level module is `prolexa/prolog/prolexa.pl`, which can either be run in
the command line or with speech input and output through the
[alexa developer console](https://developer.amazon.com/alexa/console/ask).-->



 Hyprolexa extends the functionality of the question-answering assistant Prolexa, by giving it the ability to discuss hypernyms and hyponyms for nouns.

Hyprolexa is built on Prolexa-Plus, which creates a bridge between Prolexa and Python: https://github.com/So-Cool/prolexa/tree/prolexa-plus. This bridge extends prolexa's linguistic knowledge with Wordnet from Python's Natural Language Toolkit (NLTK). 

<!--part-of-speech tagging of nouns-->

## How to talk with Hyprolexa ##

Hyprolexa loves animal facts.

```
🤖: Hello! I'm Hyprolexa! Did you know that a dog is a kind of domesticated animal? 🐕 Anyway...
🧠: a cat is a kind of feline.
*** utterance(a cat is a kind of feline)
*** rule([(isa(=>(_40780,feline(_40780)),=>(_40540,cat(_40540))):-true)])
*** [(isa(=>(_40780,feline(_40780)),=>(_40540,cat(_40540))):-true)]
🤖: Ooooooh, I will remember that a cat is a feline.
```
Once you've told Hyprolexa about a hyper-/hyponym, Hyprolexa remembers.

```
🧠: is a cat a kind of feline?
*** utterance(is a cat a feline)
*** query(isa(=>(_28752,feline(_28752)),=>(_28688,cat(_28688))))
🤖: a cat is feline
```

knowledge_store.pl is a dynamic information store which keeps information from your conversations with Hyprolexa. Hyprolexa has the additional feature of allowing you to return to previous conversations. This means Hyprolexa will remember any previous facts you told it. Knowledge stores can be found in the folder Prolexa > History.

```
🤖: Before we begin, would you like to jog my memory? Give me the name of an existing knowledge store...
🧠: knowledge_store_11161922 
🤖: Oh yes, I remember now!
```

If knowledge_store_11161922 was saved for a conversation you had about snakes, Hyprolexa will remember the relevant hypo- and hypernyms. 

```
🧠: knowledge_store_11161922 
🤖: Oh yes, I remember now!
🧠: is a viper a snake?
*** utterance(is a viper a snake)
*** query(isa(=>(_48460,snake(_48460)),=>(_48396,viper(_48396))))
🤖: a viper is snake
```

To exit your conversation with Hyprolexa and return to terminal, type 'bye'.

## Hyprolexa's Grammar ##

Hyprolexa's way of dealing with hyper- and hyponyms is based on Chapters 4 and 7 of *SimplyLogical*: https://book.simply-logical.space/ 

Hyponyms and hypernyms are stored in the format:
```
hyper(animal, 1,[organism,being]).

hypo(animal, 1,[acrodont,adult,biped,captive,chordate,creepy-crawly,critter,darter,domestic_animal,domesticated_animal,embryo,conceptus,fertilized_egg,feeder,female,fictional_animal,game,giant,herbivore,hexapod,homeotherm,homoiotherm,homotherm,insectivore,invertebrate,larva,male,marine_animal,marine_creature,sea_animal,sea_creature,mate,metazoan,migrator,molter,moulter,mutant,omnivore,peeper,pest,pet,pleurodont,poikilotherm,ectotherm,predator,predatory_animal,prey,quarry,racer,range_animal,scavenger,stayer,stunt,survivor,thoroughbred,purebred,pureblood,varmint,varment,work_animal,young,offspring,zooplankton]).
```

Input sentences about hypernyms and hyponyms are parsed in prolexa_grammar.pl. 

```
sentence1([(L:-true)]) --> a,noun(s,M1),[is],kinds(_,M2=>M1=>L),hypernym(s,M2,M1).
sentence1([(L:-true)]) --> noun(p,M1),[are],kinds(_,M2=>M1=>L),hypernym(s,M2,M1).
sentence1([(L:-true)]) --> noun(p,M1),[are],kinds(_,M2=>M1=>L),hypernym(p,M2,M1).
```

prolexa_grammar.pl is also the file which deals with queries.

```
question1(Q) --> [is],a,noun(N,M1),kinds(N,M2=>M1=>Q),noun(s,M2).
question1(Q) --> [what],kinds(N,M2=>M1=>Q),hypernym(N,M2,M1),[do,you,know].
```

## Hyprolexa's Architecture ##

The Hyprolexa.py file holds the main loop passes text from the input to Prolexa and passes the output back.

Prior to passing this input to prolog, Flair is used for part-of-speech tagging to extract nouns from the sentence. These nouns are passed to functions held in wordnet_functions.py, which searches for hypo- and hypernyms of the nouns in the Wordnet database. This information is passed to the knowledge_store and stored in the format seen above.

#### Setup and Installation ####

1. Clone this repository. 
    ```
    git clone https://github.com/TamsinHu/computer_logic.git
    ```
2. Navigate into computer_logic directory. 
    ```
    cd computer_logic
    ```   
 
3. Install requirements into your venv. 
   ```
   pip install -r requirements.txt
   ```
 
 
### Issues ###

- Currently hyprolexa has to be told about isa relationships before it can answer questions about them. It does, however, check that they are consistent with wordnet before storing the rule e.g. 'a cat is a feline' makes the rule '''rule([(isa(=>(_40780,feline(_40780)),=>(_40540,cat(_40540))):-true)])''' but won't make a rule if you type 'a cat is a monkey'. It would be much better if hyprolexa could add these rules automatically, but there was an issue with how hyprolexa stores nouns as (_40540,cat(_40540)) instead of (cat) which caused errors in the prolexa.pl list of stored rules, and with making non-grammar rules in prolexa_grammar.pl.
 
- Deal with underscores: currently underscores are removed because flair cannot tag words with underscores in as parts of speech. Unfortunately there are many underscore senses in wordnet. This means things like 'toy dog' have to be typed as 'toydog' and are returned by prolexa the same way.
 
- Extend Hyprolexa to understand nested loops so it can relate indirect hypernyms/hyponyms e.g. is a dog an animal -> a dog is a domesticated_animal, a domesticated_animal is an animal; therefore a dog is an animal.

- Use wordnet to tag word senses and import synsets into prolexa to get the correct sense of a word e.g. currently 'a dog is a kind of canine' but 'a canine is a kind of tooth'.

Questions we would like Hyprolexa to be able to answer include:

- give me some animals you know
- give me an example of each animal you know
- give me an example of every kind of animal you know
- give me a different kind of dog
- tell me everything you know about cats
- tell me all the animals you know
- list all the animals you know
- what kind of animal is a poodle - a poodle is a kind of dog
- do you know what kind of animal a poodle is
