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
        stopwords = ["halt","quit","exit","stop"]
        if input_ in stopwords:
            return True
        first_answer = meta.standardised_query(pl, input_)[0]['Output']
        print(first_answer)

    # def do_exit(self,line):
    #     """Close the gtk main loop, and return True to exit cmd."""
    #     return True

def prolexa_plus_repl():
    meta.reset_grammar()
    meta.initialise_prolexa(pl)
    ProlexaPlus().cmdloop()

if __name__ == '__main__':
    prolexa_plus_repl()