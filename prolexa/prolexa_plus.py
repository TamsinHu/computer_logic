import meta_grammar as meta
from cmd import Cmd
from pyswip import Prolog
from datetime import datetime
from shutil import copy2

pl = Prolog()

class ProlexaPlus(Cmd):
    intro = '🤖: Hello! I\'m Hyprolexa! Did you know that a dog is a kind of domesticated animal? 🐕 Anyway...'
    prompt = '🧠: '
    file = None

    def preloop(self):
        ks = input('\n🤖: Before we begin, would you like to jog my memory? Give me the name of an existing knowledge store...\n🧠: ')
        try:
            copy2(f'history/{ks}.pl', 'knowledge_store.pl')
            print('🤖: Oh yes, I remember now!\n')

            # Maybe say 'we spoke about cows and honey'
        except:
            print("🤖: That doesn't remind me of anything.\n")

    def default(self, input_):

        # Quit program using the follwing words:
        stopwords = ["bye","halt","quit","exit","stop"]
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

        # print answer
        print('🤖: ' + first_answer)

    # Type a message on quitting
    def postloop(self):
        print('🤖: Bye! Talk to you soon!')

def prolexa_plus_repl():
    meta.reset_grammar()
    meta.initialise_prolexa(pl)
    ProlexaPlus().cmdloop()

if __name__ == '__main__':
    prolexa_plus_repl()