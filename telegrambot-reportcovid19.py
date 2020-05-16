# insert your token bot here:
token = '325442748:AAEjf6eAE5EY4Tn7v366daus-z_TI3yCGUg'

import requests
from bs4 import BeautifulSoup
import logging
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

# Retorna a URL de acordo pais consultado
def geturl(country):
    return 'https://www.worldometers.info/coronavirus/country/' + country

def getdata(country):
    url = geturl(country)
    # Consulta a URL e garante que a página existe, caso não exista o else é utilziado
    print ('url:' + url )
    page = requests.get(url, allow_redirects=False)
    print ('status request: ' + str(page.status_code))
    if page.status_code == 200:
        print('200')
        soup = BeautifulSoup(page.text, 'html.parser')
        container = soup.findAll("div", {"class": "maincounter-number"})
        cases = container[0].text.strip()
        death = container[1].text.strip()
        recovered = container[2].text.strip()
        message = (country.upper() + ': \n' + \
        'Casos confirmados: ' + cases + '\n' + \
        'Óbitos: ' + death + '\n' + \
        'Recuperados: ' + recovered + '\n\n')
    else:
        print('pagina invalida')
        message = 'País não localizado, por favor use o nome em inglês\nEx: para Italia utilize "italy", e EUA utilize "US"' 
    return (message)

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

logger = logging.getLogger(__name__)

# Define a few command handlers. These usually take the two arguments update and
# context. Error handlers also receive the raised TelegramError object in error.
def start(update, context):
    """Send a message when the command /start is issued."""
    update.message.reply_text('Olá !\n Para ajuda use /help')

def help(update, context):
    """Send a message when the command /help is issued."""
    update.message.reply_text ('Função disponível:\n\
        /codid19 Italy : informa os numeros de Covid19 de cada país' )

def echo(update, context):
    """Echo the user message."""
    # Repete mensagem recebida
    #update.message.reply_text(update.message.text)
    update.message.reply_text( 'comando não reconhecido,\nuse /help para consultar' )

def error(update, context):
    """Log Errors caused by Updates."""
    print ('Função erro -----\n')
    logger.warning('Update "%s" caused error "%s"', update, context.error)

def covid19(update, context):
    """Return Covid19 Numbers"""
    print('entrou em covid19')
    print('recebido string: ' + update.message.text )
    country = update.message.text
    #Retira o início do comando da string recebida
    #Se não informar o país assume que é Brazil
    if len(country) == 8:
        country = 'brazil'
    else:
        country=country[9:]    
    print ('country: ' + country )
    print (len(country))
    answer = getdata(country)
    update.message.reply_text(answer)

def main():
    """Start the bot."""
    # Create the Updater and pass it your bot's token.
    # Make sure to set use_context=True to use the new context based callbacks
    # Post version 12 this will no longer be necessary
    updater = Updater(token, use_context=True)

    # Get the dispatcher to register handlers
    dp = updater.dispatcher

    # on different commands - answer in Telegram
    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("help", help))
    dp.add_handler(CommandHandler("covid19", covid19, pass_args=True))

    # on noncommand i.e message - echo the message on Telegram
    dp.add_handler(MessageHandler(Filters.text, echo))

    # log all errors
    dp.add_error_handler(error)

    # Start the Bot
    updater.start_polling()

    # Run the bot until you press Ctrl-C or the process receives SIGINT,
    # SIGTERM or SIGABRT. This should be used most of the time, since
    # start_polling() is non-blocking and will stop the bot gracefully.
    updater.idle()

if __name__ == '__main__':
    main()
