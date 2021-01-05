from nltk.corpus import wordnet

def get_hypernym(noun):
    #returns list of strings, hypernyms for that noun
    syns = wordnet.synsets(noun, pos='n')[0] # pos=only nouns
    hypernyms = syns.hypernyms()
    lemmas = []
    for nym in hypernyms:
        lemmas.append(nym.lemmas()[0])
    lemmas = [str(lemma.name()).lower() for lemma in lemmas]
    lemmas = str(lemmas).replace("'","").replace(" ","")
    return lemmas


def get_hyponym(noun):
    #returns list of strings, hyponyms for that noun
    syns = wordnet.synsets(noun, pos='n')[0] # pos=only nouns
    hyponyms = syns.hyponyms()
    lemmas = []
    for nym in hyponyms:
        lemmas.append(nym.lemmas()[0])
    lemmas = [str(lemma.name()).lower() for lemma in lemmas]
    lemmas = str(lemmas).replace("'","").replace(" ","")
    return lemmas
