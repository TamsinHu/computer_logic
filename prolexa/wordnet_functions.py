from nltk.corpus import wordnet

from nltk.corpus import wordnet

def get_hypernym(noun):
    #returns list of strings, hypernyms for that noun
    try:
        syns = wordnet.synsets(noun, pos='n')[0] # pos=only nouns
    except:
        return '[]'
    hypernyms = syns.hypernyms()
    lemmas = []
    for nym in hypernyms:
        for lemma in nym.lemmas():
            lemmas.append(lemma)
    lemmas = [str(lemma.name()).lower() for lemma in lemmas]
    lemmas = str(lemmas).replace("'","").replace(" ","").replace('.', '')
    return lemmas


def get_hyponym(noun):
    #returns list of strings, hyponyms for that noun
    try:
        syns = wordnet.synsets(noun, pos='n')[0]  # pos=only nouns
    except:
        return '[]'
    hyponyms = syns.hyponyms()
    lemmas = []
    for nym in hyponyms:
        for lemma in nym.lemmas():
            lemmas.append(lemma)
    lemmas = [str(lemma.name()).lower() for lemma in lemmas]
    lemmas = str(lemmas).replace("'","").replace(" ","").replace('.', '')
    return lemmas
