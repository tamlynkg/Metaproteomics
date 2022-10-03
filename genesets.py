#!/usr/bin/env python3
import matplotlib as mpl
mpl.use('agg')
import Bio; from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq, translate
import pandas as pd
from pandas import DataFrame,  Series
import json
import collections; from collections import defaultdict
import tempfile
from matplotlib_venn import venn3, venn2, venn3_circles, venn2_circles
from matplotlib import pyplot as plt
import shutil
import numpy as np
import algo
import time
import re
import os
import subprocess
import yaml
import scikit_posthocs as ph
import scipy
import pickle
import mygene
import sys
from io import StringIO



def ips_genesets(self, ipr, proteins, outpath, keggid='ko', id_col="Leading Protein"):
        ipr = '/Users/tamlyngangiah/Desktop/InterproscanProteinIDproteinsequences.csv'
        outpath = '/Users/tamlyngangiah/Desktop'
        proteins = '/Users/tamlyngangiah/Desktop/proteinGroups.txt'
        cols = ['ProteinAccession', 
                'MD5', 
                'Length', 
                'Analysis', 
                'SignatureAccession',
                'SignatureDescription',
                'Start',
                'Stop',
                'Score',
                'Status',
                'Date',
                'InterProAnnotationsAccession',
                'InterProAnnotationsDescription',
                'GoAnnotations',
                'PathwaysAnnotations' ]
        data = pd.read_csv(ipr, sep=',', names = cols,  engine='python')
        lst_col = 'ProteinAccession' 
        x = data.assign(**{lst_col:data[lst_col].str.split('|')})
        data = pd.DataFrame({col:np.repeat(x[col].values, x[lst_col].str.len()) for col in x.columns.difference([lst_col])}).assign(**{lst_col:np.concatenate(x[lst_col].values)})[x.columns.tolist()]
        
        
        # GO Terms
        id2go= defaultdict(set)
        gos = set()
        def go(df):
            outpath = '/Users/tamlyngangiah/Desktop'
            go = df['GoAnnotations']
            id = df['ProteinAccession']
            try:
                go=go.split('|')
                id2go[id].update(go)
                for goterm in go:
                    gos.add(goterm)
            except:
                pass
        data.apply(go, axis=1)
        with open( outpath +'/accession2go.p', 'wb') as f:
            pickle.dump( id2go, f)
        go_df = pd.DataFrame()
        go_vals = list(gos)
        go_df['GO_ID'] = pd.Series(go_vals)
        go_df.to_csv(outpath +'/go_terms.csv')

        def gointersect(val):
            vals = val.split(';')
            setlist = []
            for val in vals:
                vset = id2go[val]
                setlist.append(vset)
            union = set.union(*setlist)
            if len(union) > 0:
                return ';'.join(union)
        proteins['_go.term.union']   = proteins[id_col].apply(parse_ids).apply(gointersect)
        
        go2pg = defaultdict(set)
        def go2gene(df):
            outpath = '/Users/tamlyngangiah/Desktop'
            go_terms = df['_go.term.union']
            pg = df['Identifier']
            try:
                go_terms = go_terms.split(';')
                for _ in go_terms:
                    go2pg[_].add(pg)
            except:
                pass
        proteins.apply(go2gene,axis=1)

        go_df = pd.DataFrame()
        go_df['GO_ID'] = pd.Series(list(go2pg.keys()))
        go_df['GENES'] = pd.Series(list(go2pg.values())).apply( lambda x  : '|'.join(x))
        
        go_df.to_csv(outpath +'/go2proteingroups.csv')
