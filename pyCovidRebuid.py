#!/usr/bin/env python3.7
# coding: utf8

"""
    Bibliothèque pour représenter les Réseaux de Pétri (RdP) classiques.
    TODO :
    - ...
"""

import xml.etree.ElementTree as ET
import collections
import sys

liste_pays = {}
Liste_annees = collections.OrderedDict()
# ==================================================
# ==================================================
# ==================================================
if __name__ == '__main__':
    tree = ET.parse(sys.argv[1]) #'covid19-eu-monde-2020-11-11.xml')
    U = tree.getroot()
    for x in U :
        gid = x[7].text
        nom = x[6].text.replace('_',' ')
        ctc = x[8].text
        if ctc is None: ctc = ''
        pop = x[9].text
        if pop is None: pop = '0'
        cont = x[10].text
        if cont is None: cont=''
        if gid not in liste_pays.keys() :
            pays = { 'nom': nom, 'gid' : gid, 
                     'ctc': ctc, 'pop' : pop, 'continent' : cont }
            liste_pays[gid] = pays
        annee = x[3].text
        mois = x[2].text
        jour = x[1].text

        if annee not in Liste_annees.keys():
            Liste_annees[annee] = collections.OrderedDict()
        liste_mois = Liste_annees[annee]
        if mois not in liste_mois.keys() :
            liste_mois[mois] = collections.OrderedDict()
        liste_jours = liste_mois[mois]
        if jour not in liste_jours.keys() :
            liste_jours[jour] = []
        liste_releves = liste_jours[jour]
        cumul = x[11].text
        if cumul is None: cumul='0'
        liste_releves.append(  [ x[7].text, x[4].text, x[5].text, cumul ]  )

    print("<?xml version='1.0' encoding='UTF-8'?>")
    print("<!DOCTYPE covid-ue SYSTEM 'covid.dtd'>")
    print("<covid-ue>")
    print(" <country_list>")
    for p in liste_pays.values():
        print("     <country xml:id='"+p['gid']+"' name='"+p['nom']+
                          "' country-territory-code='"+ p['ctc'] +"' population='"+ p['pop'] +
                          "' continent='"+ p['continent']   +"'/>")

    print(" </country_list>")
    print(" <record_list>")
    for (a, lm) in Liste_annees.items() :
        print("     <year no='"+ a +"'>")
        for (m,lj) in lm.items() :
            print("         <month no='"+ m +"'>")
            for (j,lr) in lj.items():
                print("             <day no='"+j+"'>")
                for x in lr :
                    print("                 <record date='"+ annee + "-"+mois+"-"+jour +
                                        "' country='"+ x[0] +
                                        "' cases='"+ x[1] +
                                        "' deaths='"+ x[2] +
                                        "' cumulative-14-days-per-100000='"+ x[3] +"'/>")
                print("             </day>")
            print("         </month>")
        print("     </year>")
    print(" </record_list>")
    print("</covid-ue>")