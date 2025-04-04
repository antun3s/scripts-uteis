#!/usr/bin/env python
# coding: utf-8

from requests import get
from bs4 import BeautifulSoup
import re

def get_data_cnpjsrocks(cnpj):
    cidade = None
    uf = None
    razaosocial = None
    email = None
    telefone = None
    
    response = get( "https://cnpjs.rocks/cnpj/" + str(cnpj) ) 
    html_soup = BeautifulSoup(response.text, 'html.parser' )
    
    elems = html_soup.findAll( "li")

    for elem in elems:
        if elem.text.find("Muni") > -1:
            cidade = re.sub("(.*:\ \ )", '', elem.text)
            #print ( "Cidade: {}".format(cidade) )

        if elem.text.find("UF") > -1:
            uf = re.sub("(.*:\ \ )", '', elem.text)
            #print ( "UF: {}".format(uf) )

        if elem.text.find("o Social") > -1:
            razaosocial = re.sub("(.*:\ \ )", '', elem.text)
            #print ( "Razao Social: {}".format(razaosocial) )

        if elem.text.find("E-mail") > -1:
            email = re.sub("(.*:\ \ )", '', elem.text)
            #print ( "E-mail: {}".format(email) )

        if elem.text.find("Telefone") > -1:
            telefone = re.sub("(.*:\ \ )", '', elem.text)
            #print ( "Telefone: {}".format(telefone) )

    return( razaosocial, cidade, uf, telefone, email )

file = open("cnpj.txt", "r")
for cnpj in file:
    print( "{},{}".format(cnpj,get_data_cnpjsrocks(cnpj)))
