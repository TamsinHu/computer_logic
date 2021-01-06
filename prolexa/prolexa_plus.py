import meta_grammar as meta
from cmd import Cmd
from pyswip import Prolog
from datetime import datetime
from shutil import copy2

pl = Prolog()

from prolexa import PACKAGE_PATH, PROLOG_PATH


class ProlexaPlus(Cmd):
    intro = 'Hello! I\'m ProlexaPlus! Tell me anything, ask me anything.'
    prompt = '> '
    file = None

    def preloop(self):
        input('Would you like me to remember previous knowledge?')

    def default(self, input_):

        # Quit program using the follwing words:
        stopwords = ["halt","quit","exit","stop"]
        if input_ in stopwords:
            time = datetime.now().strftime("%d%H%M%S")
            copy2('knowledge_store.pl', f'history/knowledge_store_{time}.pl')
            return True

        # Get prolexa's top answer
        first_answer = str(meta.standardised_query(pl, input_)[0]['Output'])

        # remove weird b character from beginning of answers to questions
        if first_answer.startswith("b'"):
            first_answer = first_answer.lstrip('b')
            first_answer = first_answer.strip("'")
        print(first_answer)

    def postloop(self):
        print('Bye! Talk to you soon!')

def prolexa_plus_repl():
    meta.reset_grammar()
    meta.initialise_prolexa(pl)
    ProlexaPlus().cmdloop()

if __name__ == '__main__':
    prolexa_plus_repl()