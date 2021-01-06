#! /usr/bin/env python

import os
from cmd import Cmd
from pyswip import Prolog

# import warnings
# warnings.filterwarnings("ignore")

# import prolexa.meta_grammar as meta
import meta_grammar as meta

pl = Prolog()

class ProlexaPlus(Cmd):
    intro = 'Hello! I\'m ProlexaPlus! Tell me anything, ask me anything.'
    prompt = '> '
    file = None

    def default(self, input_):

        # Quit program using the follwing words:
        stopwords = ["halt","quit","exit","stop"]
        if input_ in stopwords:
            return True

        # Get prolexa's top answer
        first_answer = str(meta.standardised_query(pl, input_)[0]['Output'])

        # remove weird b character from beginning of answers to questions
        if first_answer.startswith("b'"):
            first_answer = first_answer.lstrip('b')
            first_answer = first_answer.strip("'")
        print(first_answer)

        ### add emojis as prompts?


def prolexa_plus_repl():
    meta.reset_grammar()
    meta.initialise_prolexa(pl)
    ProlexaPlus().cmdloop()

if __name__ == '__main__':
    prolexa_plus_repl()