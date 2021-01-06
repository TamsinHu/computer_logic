import contractions
import os
import re
import string
from copy import deepcopy

from enum import Enum
from flair.data import Sentence
from flair.models import SequenceTagger
from nltk.stem import WordNetLemmatizer

from prolexa import PACKAGE_PATH, PROLOG_PATH

import wordnet_functions as wnf

PROLOG_DET_REGEX = r'determiner\([a-z],X=>B,X=>H,\[\(H:-B\)\]\)(.*)'
PROLOG_DET = 'determiner(p,X=>B,X=>H,[(H:-B)]) --> [{}].\n'

# PartsOfSpeech
# https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html
class POS(Enum):
    DETERMINER = 'DT'
    ADVERB = 'RB'
    PROPNOUN = 'NNP'
    PROPNOUN_2 = 'PROPN'
    NOUN = 'NN'
    VERB = 'VB'
    ADJECTIVE = 'JJ'
    PREPOSITION = 'IN'
    COORD = 'CC'
    CARDINAL = 'CD'
    EXISTENTIAL = 'EX'
    FOREIGN = 'FW'
    LISTITEM = 'LS'
    MODAL = 'MD'
    PREDET = 'PDT'
    POSSESS = 'POS'
    PRONOUN = 'PRP'
    POSSPRONOUN = 'PRP$'
    PARTICLE = 'RP'
    SYMBOL = 'SYM'
    TO = 'TO'
    INTERJECTION = 'UH'
    WHDET = 'WDT'
    WHPRONOUN = 'WP'
    WHADVERB = 'WRB'

class Tagger():
    def __init__(self):
        self.tagger = SequenceTagger.load('pos')

    def tag(self, text):
        sentence = Sentence(text)

        # predict POS tags
        self.tagger.predict(sentence)
        tagged_sent = sentence.to_tagged_string()
        tags = re.findall(re.escape('<') + '(.*?)' + re.escape('>'),
                          tagged_sent)

        return tagged_sent, sentence.to_plain_string(), tags

tagger = Tagger()

def initialise_prolexa(pl):
    #pl.consult(os.path.join(PROLOG_PATH, 'prolexa.pl'))
    pl.consult(os.path.join(PACKAGE_PATH, 'prolexa.pl'))

def update_knowledge_store(pl):
    list(pl.query('make'))

def reset_grammar():
    lines = get_prolog_grammar(PROLOG_PATH, 'prolexa_grammar.pl')
    write_new_grammar(PACKAGE_PATH, lines)

    lines = get_prolog_grammar(PROLOG_PATH, 'prolexa.pl')
    write_new_prolexa(PACKAGE_PATH, lines)

def get_prolog_grammar(path, fname):
    with open(os.path.join(path, fname), 'r') as f:
        lines = f.readlines()
    return lines

def write_new_grammar(path, lines):
    with open(os.path.join(path, 'knowledge_store.pl'), 'w') as f:
        lines = ''.join(lines)
        f.write(lines)

def write_new_prolexa(path, lines):
    with open(os.path.join(path, 'prolexa.pl'), 'w') as f:
        lines = ''.join(lines)
        l = lines.replace('consult(prolexa_engine)',
                          'consult(prolog/prolexa_engine)')
        l = l.replace('consult(prolexa_grammar)',
                      'consult(knowledge_store)')
        f.write(l)

def escape_and_call_prolexa(pl, text):

    # Update the knowledge base
    update_rules(tagger, text)
    #update_knowledge_store(pl)

    # Start Prolexa
    initialise_prolexa(pl)

    # Ask the question / run the command etc.
    libPrefix = 'prolexa:'
    generator = pl.query(libPrefix + handle_utterance_str(text))
    return list(generator)

def lemmatise(word):
    wnl = WordNetLemmatizer()
    return wnl.lemmatize(word, 'n')

def is_plural(word):
    lemma = lemmatise(word)
    plural = True if word is not lemma else False
    return plural, lemma

def handle_utterance_str(text):
    if text[0] != "'" and text[0] != '"' :
        text = f'"{text}"'

    text = text.replace('"', '\"')
    text = text.replace("'", '\"')

    return 'handle_utterance(1,{},Output)'.format(text)

def remove_punctuation(s):
    return s.translate(str.maketrans('', '', string.punctuation))

def standardised_query(pl, text):
    text = remove_punctuation(text)
    text = contractions.fix(text)
    text = lemmatise(text)
    return escape_and_call_prolexa(pl, text)

# for queries, not knowledge loading
def standardise_tags(tags):
    std = []
    for tag in tags:
        if POS.DETERMINER.value in tag:
            std.append( POS.DETERMINER.value)
        elif POS.VERB.value in tag:
            std.append( POS.VERB.value)
        elif POS.ADVERB.value in tag:
            std.append( POS.ADVERB.value)
        elif POS.ADJECTIVE.value in tag:
            std.append( POS.ADJECTIVE.value)
        elif POS.NOUN.value in tag and tag != POS.PROPNOUN.value:
            std.append( POS.NOUN.value)
        else:
            std.append(tag)
    return std

def get_tags(tagger, text):
    _, _, tags = tagger.tag(text)
    tags = standardise_tags(tags)
    return tags


def handle_hyper(lines, i, hyper_text, hyper_tags):
    nn = POS.NOUN.value
    start = 'hyper('
    end = ', '
    exists = False
    new_line = ''
    input_word = hyper_text[hyper_tags.index(nn)]
    _, input_word = is_plural(input_word)
    hyper_text[hyper_tags.index(nn)] = input_word

    ### CALL FUNCTION TO GET HYPERNYMS OF INPUT_WORD AS A LIST OF STRINGS
    hypernyms = wnf.get_hypernym(input_word)
    ### CALL FUNCTION TO GET HYPONYMS OF INPUT_WORD AS A LIST OF STRINGS

    ### FUNCTION TO ADD ALL HYPERNYMS AND HYPONYMS AS PREDICATES

    # for all the lines after the fist predicate definition
    for noun_idx, noun_line in enumerate(lines[i:]):

        # if noun_line is a line past where the predicates are stored in the knowledge base
        # then remove the current word and corresponding tag from the input list
        if not(re.match(r'hyper\((.*)[1],\[(.*)\]\)\.', noun_line)):
            noun_idx = noun_idx + i
            if hyper_tags:
                hyper_tags.remove(nn)
            if hyper_text:
                hyper_text.remove(input_word)
            break

        # get the part of the knowledge base predicate after 'pred(' and before ', ').
        line_word = (noun_line.split(start))[1].split(end)[0]

        ### ADD A CASE FOR EDITING EXISTING ENTRIES

        # if it matches the input word
        if input_word == line_word:
            # delete it from the list of input words
            exists = True
            if hyper_tags:
                hyper_tags.remove(nn)
            if hyper_text:
                hyper_text.remove(input_word)
            break

    # if it is not in the knowledge base at all, add it
    if not exists:
        if new_line == '':
            new_line = 'hyper(' + input_word + ', 1,' + hypernyms + ').\n'
        lines.insert(noun_idx, new_line)

    return lines


def handle_hypo(lines, i, hypo_text, hypo_tags):
    nn = POS.NOUN.value
    start = 'hypo('
    end = ', '
    exists = False
    new_line = ''
    input_word = hypo_text[hypo_tags.index(nn)]
    _, input_word = is_plural(input_word)
    hypo_text[hypo_tags.index(nn)] = input_word

    hyponyms = wnf.get_hyponym(input_word)

    # for all the lines after the fist predicate definition
    for noun_idx, noun_line in enumerate(lines[i:]):

        # if noun_line is a line past where the predicates are stored in the knowledge base
        # then remove the current word and corresponding tag from the input list
        if not(re.match(r'hypo\((.*)[1],\[(.*)\]\)\.', noun_line)):
            noun_idx = noun_idx + i
            if hypo_tags:
                hypo_tags.remove(nn)
            if hypo_text:
                hypo_text.remove(input_word)
            break

        # get the part of the knowledge base predicate after 'pred(' and before ', ').
        line_word = (noun_line.split(start))[1].split(end)[0]

        ### ADD A CASE FOR EDITING EXISTING ENTRIES

        # if it matches the input word
        if input_word == line_word:
            # delete it from the list of input words
            exists = True
            if hypo_tags:
                hypo_tags.remove(nn)
            if hypo_text:
                hypo_text.remove(input_word)
            break

    # if it is not in the knowledge base at all, add it
    if not exists:
        if new_line == '':
            new_line = 'hypo(' + input_word + ', 1,' + hyponyms + ').\n'
        lines.insert(noun_idx, new_line)

    return lines


def handle_noun(lines, i, text, tags):
    nn = POS.NOUN.value
    start = 'pred('
    end = ', '
    exists = False
    new_line = ''
    input_word = text[tags.index(nn)]
    _, input_word = is_plural(input_word)
    text[tags.index(nn)] = input_word

    # for all the lines after the fist predicate definition
    for noun_idx, noun_line in enumerate(lines[i:]):

        # if noun_line is a line past where the predicates are stored in the knowledge base
        # then remove the current word and corresponding tag from the input list
        if not(re.match(r'pred\((.*)[1],\[(.*)\]\)\.', noun_line)):
            noun_idx = noun_idx + i

            if tags:
                tags.remove(nn)
            if text:
                text.remove(input_word)
            break

        # get the part of the knowledge base predicate after 'pred(' and before ', ').
        line_word = (noun_line.split(start))[1].split(end)[0]

        # if it matches the input word
        if input_word == line_word:
            # delete it from the list of input words
            if (re.match(r'pred\((.*)[1](.*)n\/(.*)\]\)\.', noun_line)):
                exists = True
                if tags:
                    tags.remove(nn)
                if text:
                    text.remove(input_word)
                break
            # if it exists but not as a noun, add it as a noun and then delete if from list of input words
            else:
                noun_idx = noun_idx + i
                insert_idx = noun_line.index(']).')
                new_line = (noun_line[:insert_idx]
                            + ',n/'
                            + input_word
                            + noun_line[insert_idx:])
                lines[noun_idx] = new_line
                exists = True
                if tags:
                    tags.remove(nn)
                if text:
                    text.remove(input_word)
                break

    # if it is not in the knowledge base at all, add it
    if not exists:
        if new_line == '':
            new_line = 'pred(' + input_word + ', 1,[n/' + input_word + ']).\n'
        lines.insert(noun_idx, new_line)

    return lines

def handle_adjective(lines, i, text, tags):
    a = POS.ADJECTIVE.value
    start = 'pred('
    end = ', '
    exists = False
    new_line = ''
    input_word = text[tags.index(a)]
    _, input_word = is_plural(input_word)
    text[tags.index(a)] = input_word

    for noun_idx, noun_line in enumerate(lines[i:]):
        if not(re.match(r'pred\((.*)[1],\[(.*)\]\)\.', noun_line)):
            noun_idx = noun_idx + i
            if tags:
                tags.remove('JJ')
            if text:
                text.remove(input_word)
            break
        line_word = (noun_line.split(start))[1].split(end)[0]
        if input_word == line_word:
            if (re.match(r'pred\((.*)[1](.*)a\/(.*)\]\)\.', noun_line)):
                exists = True
                if tags:
                    tags.remove(a)
                if text:
                    text.remove(input_word)
                break
            else:
                noun_idx = noun_idx + i
                insert_idx = noun_line.index(']).')
                new_line = (noun_line[:insert_idx]
                            + ',a/'
                            + input_word
                            + noun_line[insert_idx:])
                lines[noun_idx] = new_line
                exists = True
                if tags:
                    tags.remove(a)
                if text:
                    text.remove(input_word)
                break

    if not exists:
        if new_line == '':
            new_line = 'pred(' + input_word + ', 1,[a/' + input_word + ']).\n'
        lines.insert(noun_idx, new_line)

    return lines

def handle_verb(lines, i, text, tags):
    v = POS.VERB.value
    start = 'pred('
    end = ', '
    exists = False
    new_line = ''
    input_word = text[tags.index(v)]
    _, input_word = is_plural(input_word)
    text[tags.index(v)] = input_word

    for noun_idx, noun_line in enumerate(lines[i:]):
        if not(re.match(r'pred\((.*)[1],\[(.*)\]\)\.', noun_line)):
            noun_idx = noun_idx + i
            if tags:
                tags.remove(v)
            if text:
                text.remove(input_word)
            break

        line_word = (noun_line.split(start))[1].split(end)[0]
        if input_word == line_word:
            if (re.match(r'pred\((.*)[1](.*)v\/(.*)\]\)\.', noun_line)):
                exists = True
                if tags:
                    tags.remove(v)
                if text:
                    text.remove(input_word)
                break
            else:
                noun_idx = noun_idx + i
                insert_idx = noun_line.index(']).')
                new_line = (noun_line[:insert_idx]
                            + ',v/'
                            + input_word
                            + noun_line[insert_idx:])
                lines[noun_idx] = new_line
                exists = True
                if tags:
                    tags.remove(v)
                if text:
                    text.remove(input_word)
                break

    if not exists:
        if new_line == '':
            new_line = 'pred(' + input_word + ', 1,[v/' + input_word + ']).\n'
        lines.insert(noun_idx, new_line)

    return lines

def handle_proper_noun(lines, i, text, tags):
    prop = POS.PROPNOUN.value
    start = '--> ['
    end = ']'
    exists = False
    input_word = text[tags.index(prop)]
    for det_idx, det_line in enumerate(lines[i:]):
        if not(re.match(r'proper_noun\(s(.*) -->(.*)\]\.', det_line)):
            det_idx = det_idx + i
            if tags:
                tags.remove(prop)
            if text:
                text.remove(input_word)
            break
        line_word = (det_line.split(start))[1].split(end)[0]
        if input_word == line_word:
            exists = True
            if tags:
                tags.remove(prop)
            if text:
                text.remove(input_word)
            break

    if not exists:
        new_line = 'proper_noun(s,{}) --> [{}].\n'.format(
            input_word, input_word)
        lines.insert(det_idx, new_line)

    return lines

def update_rules(tagger, text):

    # Get PoS tags for each word in input text
    tags = get_tags(tagger, text)
    text = text.lower()
    # Handle extra whitespace
    text = ' '.join(text.split()).split(' ')
    start = ''
    end = ''
    hyper_tags = deepcopy(tags)
    hypo_tags = deepcopy(tags)
    hyper_text = deepcopy(text)
    hypo_text = deepcopy(text)

    # Extract all the knowledge from the knowledge store
    lines = get_prolog_grammar(PACKAGE_PATH, 'knowledge_store.pl')

    # Go through the knowledge line by line
    for idx, line in enumerate(iter(lines)):
        if not text:
            break

        # RECORD HYPERNYMS
        hyper_match = r'hyper\((.*)[1],\[(.*)\]\)\.'

        if (POS.NOUN.value in hyper_tags) and re.match(hyper_match, line):
            lines = handle_hyper(lines, idx, hyper_text, hyper_tags)

        # RECORD HYPONYMS
        hypo_match = r'hypo\((.*)[1],\[(.*)\]\)\.'
        if (POS.NOUN.value in hypo_tags) and re.match(hypo_match, line):
            lines = handle_hypo(lines, idx, hypo_text, hypo_tags)

        # Check to find the place in knowledge store where other predicates are saved
        pred_match = r'pred\((.*)[1],\[(.*)\]\)\.'


        # Handle Nouns, Adjectives and Verbs as predicates
        if (POS.NOUN.value in tags) and re.match(pred_match, line):
            lines = handle_noun(lines, idx, text, tags)

        if (POS.ADJECTIVE.value in tags) and re.match(pred_match, line):
            lines = handle_adjective(lines, idx, text, tags)

        if (POS.VERB.value in tags) and re.match(pred_match, line):
            lines = handle_verb(lines, idx, text, tags)

        # Handle Proper Nouns as rules
        prop_match = r'proper_noun\(s(.*) -->(.*)\]\.'

        if (POS.PROPNOUN.value in tags) and re.match(prop_match, line):
            lines = handle_proper_noun(lines, idx, text, tags)

    # Write a new knowledge base incorporating input
    write_new_grammar(PACKAGE_PATH, lines)
