#!/usr/bin/python
# Copyright 2014 BARRIOT Roland
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse

# SCRIPT PARAMETERS
parser = argparse.ArgumentParser(description='Perform on a .pri file.')
parser.add_argument('--pris', required=False, help='file containing results of multiple priorizations (scores delimited by tabs).')
parser.add_argument('--pri', nargs='*', required=False, help='file containing results of a single priorization.')
parser.add_argument('--training', required=True, help='training genes.')
parser.add_argument('--plot', required=False, action="store_true", help='draw plot.')
parser.add_argument('--save-plot', required=False, help='save plot as...')
param = parser.parse_args()

import Prioritization

training = param.training.split()

if param.pris:
	pris = Prioritization.Prioritizer.load_pris(param.pris)
elif param.pri:
	import numpy as np
	ids = {} # ids[ id ] [ datasource ]  = score
	for filename in param.pri:
		for i in Prioritization.Prioritizer.load_pri(filename):
			if i.id not in ids:
				ids[ i.id ] = {}
			ids[ i.id ][ filename ] = float(i.score)
	pris = { 'id': ids.keys(), 'head': param.pri, 'matrix': None }
	mat = []
	for i in pris['id']:
		row = []
		for j in pris['head']:
			if i in ids and j in ids[ i ]:
				row.append( ids[ i ][ j ])
			else:
				row.append( float("nan") )
		mat.append(row)
	pris['matrix'] = np.matrix(mat)
fus = Prioritization.Prioritizer.fusion(pris['id'], training, pris['matrix'], pris['head'])

colnames = pris['head'][:]
colnames.insert(0,'fusion')
print 'gene\t'+'\t'.join(colnames)
for i in fus['genes']:
	print i['id']+'\t'+str(i['fusion']) ,
	for j in pris['head']:
		print '\t'+str(i[j]) ,
	print

if param.plot:
	Prioritization.Prioritizer.plot(fus, training, colnames)

if param.save_plot is not None:
	Prioritization.Prioritizer.plot(fus, training, colnames, save_as=param.save_plot)
