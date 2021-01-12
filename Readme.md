
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

#### Initial setup ####

1. Clone this repository
    ```
    git clone https://github.com/TamsinHu/computer_logic.git
    ```
    


## Installation ##

<!--
### `pip install` ###
This installation approach is recommended.
The installation script may take a moment when processing the Prolexa package
since language models need to be downloaded (which is achieved by automatically
executing the `prolexa/setup_models.py` script) -- the
`Running setup.py install for prolexa ... /` step.

To install execute
```
pip install -e .
```
while in the root directory of this repository.
The `-e` flag installs an editable version of the package, which allows you to
edit the source to instantly update the installed version of the package
(read more
[here](https://pip.pypa.io/en/stable/reference/pip_install/#install-editable)).

This installation comes with two command line tools:

* `prolexa-plus` -- **launches the Prolexa Plus CLI**, and
* `prolexa-setup-models` -- downloads `nltk` and `flair` language corpora and
  models.

### Executing Source ###
<!--1. Install Python dependencies
   ```
   pip install -r requirements.txt
   ```
2. Install language models and data
   ```
   python prolexa/setup_models.py
   ```
3. Run *Prolexa Plus*
   ```
   PYTHONPATH=./ python prolexa/prolexa_plus.py
   ```
-->
