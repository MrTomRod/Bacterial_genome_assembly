#bin/python

import sys
import os
import networkx as nx
import matplotlib.pyplot as plt
import math
import operator
import numpy as np

#usage: indexstat assembly.fasta factor_keep(0.0-1.0) optional:notused.fasta

inputOptions = sys.argv[1:]


factor_to_keep=float(inputOptions[2])

def main():


	sequences=read_sequences(inputOptions[0])
	sequences=read_coverages(inputOptions[1], sequences)
	genome_median_coverage=calculate_median_cov(sequences)

	scaffold_counter=0
	unused_scaffold_counter=0
	for sequence in sequences.values():
		assert(sequence.avg_rpb!="-")

	for sequence in sorted(sequences.values(), key=lambda Sequence: Sequence.sequence_length(), reverse=True):
		
		if sequence.avg_rpb >= genome_median_coverage*factor_to_keep and sequence.sequence_length() >= 200:
			scaffold_counter+=1
			print ">scaffold_0000"[0:len(">scaffold_0000")-len(str(scaffold_counter))]+str(scaffold_counter)+" len_"+str(sequence.sequence_length())+"|rpb_"+str(round(sequence.avg_rpb, 4))+sequence.sequence
			
		elif len(inputOptions) == 4:
			unused_scaffold_counter+=1
			with open(inputOptions[3], 'a') as file:
    				file.write(">unused_scaffold_0000"[0:len(">unused_scaffold_0000")-len(str(unused_scaffold_counter))]+str(unused_scaffold_counter)+" len_"+str(sequence.sequence_length())+"|rpb_"+str(round(sequence.avg_rpb, 4))+" (median coverage: rpb_"+str(round(genome_median_coverage,4))+")"+sequence.sequence+"\n")



def read_coverages(indexstat_file, sequences):
	coverage_file = [n for n in open(indexstat_file,'r').read().replace("\r","").split("\n") if len(n)>0]

	for line in coverage_file:
		if int(line.split("\t")[1])>0:
			key=line.split("\t")[0]
			sequences[key].avg_rpb=float(line.split("\t")[2])/float(line.split("\t")[1])

			assert(sequences[key].sequence_length()==float(line.split("\t")[1]))
			
	return sequences

def calculate_median_cov(sequences):
	read_counts_per_bp=list()
	for sequence in sequences.keys():
		if sequences[sequence].sequence_length() >= 5000:
			for i in range(0,sequences[sequence].sequence_length()):
				read_counts_per_bp.append(sequences[sequence].avg_rpb)

	return (np.median(read_counts_per_bp))

def read_sequences(fasta_file):
	file_fasta = [n for n in open(fasta_file,'r').read().replace("\r","").split("\n") if len(n)>0]
	sequences={}
	for line in file_fasta:
		if line[0:1]==">":
			key=line[1:].split(" ")[0]
			sequence=Sequence(key)
			sequences[key]=sequence

		else:
			sequences[key].sequence+="\n"+line.replace("*","")
			
	return sequences		




class Sequence:
	def __init__(self, name):
		self.name=name
		self.sequence=""
		self.length=0
		self.avg_rpb="-" # rpb = (counted) reads per base

	def sequence_length(self):
		return len(self.sequence.replace("\n",""))
		


main()

