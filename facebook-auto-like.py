from selenium import webdriver
from time import sleep
from pynput.keyboard import Key, Controller

# Download chrome webdrive here: https://chromedriver.chromium.org/downloads
chromedriver = '/home/antunes/scripts/scripts-pessoais/chromedriver'
driver = webdriver.Chrome(chromedriver)

def facebooklogin():
    driver.get('https://www.facebook.com/')
    driver.find_element_by_id('email').send_keys('facebooklogin')
    driver.find_element_by_id('pass').send_keys('facebookpass')
    driver.find_element_by_id('u_0_a').click()

facebooklogin()

def like():
    keyboard = Controller()
    sleep(1)
    keyboard.press('j')
    keyboard.release('j')
    sleep(1)
    keyboard.press('l')
    keyboard.release('l')

sleep(2)
for i in range (0,1000):
    print ('rodada', i)
    if i % 30 == 0:
        print('refresh')
        driver.refresh()
    like()
