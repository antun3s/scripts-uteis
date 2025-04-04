import PySimpleGUI as sg
import os

def run(processname, processexecute):
    if os.system('pgrep '+processname) != 0:
        os.system(processexecute)

def deb_logon():
    run('firefox','/usr/lib/firefox/firefox &')
    run('terminator','terminator &')
    run('/home/antunes/Telegram/Telegram','/home/antunes/Telegram/Telegram -- %u &')
    os.system('sleep 1')
    run('/usr/bin/thunderbird','/usr/bin/thunderbird &')
    run('slack','/usr/bin/slack %U &')
    run('java','jitsi &')
    os.system('sleep 1')
    window.Close()

def deb_logout():
    os.system('killall -9 thunderbird &')
    os.system('killall -9 slack &')
    os.system('killall -9 shutter &')
    os.system('killall -9 anydesk &')
    os.system('killall -9 remmina &')
    os.system('killall -9 keepassx &')
    os.system('ps aux | grep -i jitsi | grep -i java | awk \'{print "kill -9 "$2}\' | sh &')
    os.system('ps aux | grep -i keepassx | awk \'{print "kill -9 "$2}\' | sh &')
    os.system('sleep 1')
    window.Close()

sg.theme('DarkGrey5')

layout = [[sg.Text('Selecione o comando', size=(20, 1), font=("Roboto", 12), text_color='grey')],
          [sg.Button('Logon',key='_LOGON_'),sg.Button('Logout', key='_LOGOUT_'), sg.Cancel(key='_CANCEL_')]]

window = sg.Window('Logon Deb').Layout(layout)  

while True:  
    event, values = window.Read()  
    if event is None:  
        break  
    if event == '_LOGON_':
        deb_logon()
    elif event == '_LOGOUT_':
        deb_logout()
    elif event == '_CANCEL_':
        window.Close()
    else:
        print('erro generico')
