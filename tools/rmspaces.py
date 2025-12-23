#!/usr/bin/env python3

import os
import re
import sys
import copy
import glob
import time
import shutil

#pip3 libraries
import unicodedata
# Add transliterate library for better language-specific handling
import transliterate

#==============
def unicode_to_string(data: str) -> str:
	"""
	Converts Unicode text to a string with only ASCII characters,
	transliterating where possible and stripping non-ASCII characters.
	"""
	orig_data = copy.copy(data)
	try:
		# Ensure the input is a Unicode string
		if isinstance(data, bytes):
			data = data.decode("utf-8")
	except UnicodeDecodeError as e:
		print(f"Error decoding data: {e}")
		return ""

	# Attempt transliteration using transliterate
	try:
		transliterated = transliterate.translit(data, reversed=True)
	except Exception:
		transliterated = data  # If transliterate fails, use the original data

	# Normalize the string to decompose accents and diacritics (NFKD normalization)
	nfkd_form = unicodedata.normalize('NFKD', transliterated)

	# Remove non-ASCII characters by encoding to ASCII and ignoring errors
	ascii_bytes = nfkd_form.encode('ASCII', 'ignore')

	# Decode back to string and return
	ascii_only = ascii_bytes.decode('ASCII')
	#print(f"unicode_to_string: {orig_data} -> {ascii_only}")
	return ascii_only

#=======================
def cleanName(f):
	# Words to preserve or format correctly
	words = ['of', 'the', 'a', 'in', 'for', 'am', 'is', 'on',
			'la', 'to', 'than', 'with', 'by', 'from', 'or', 'and']

	# Allowed characters
	goodchars = list('-./_'
					+ '0123456789'
					+ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
					+ 'abcdefghijklmnopqrstuvwxyz')

	# Transliterate filename to ASCII
	g = unicode_to_string(f)
	g = g.strip()

	# Handle filenames with numbers in parentheses at the end
	match = re.search(r"\((\d+)\)(\.[a-zA-Z0-9]+)?$", g)  # Find "(number)" + optional extension
	if match:
		number = int(match.group(1))  # Extract the number
		extension = match.group(2) if match.group(2) else ""  # Extract the extension if it exists
		g = re.sub(r"\s*\(\d+\)", "", g)  # Remove the "(number)" part
		g += f"_{number:04d}{extension}"  # Append "_0000" format

	# Preserve file extension casing
	if os.path.isfile(f) and len(g) > 7 and g[-4] == ".":
		g = g[:-4] + g[-4:].lower()

	# Replace spaces and unwanted patterns
	g = re.sub(" ", "_", g)
	g = re.sub(r"[Ww]{3}\.", "", g)
	g = re.sub(r"\._\.", "_", g)
	g = re.sub(r"^-*", "", g)
	g = re.sub(r"\'", "_", g)
	g = re.sub(r"\"", "_", g)
	g = re.sub(r"&", "and", g)
	g = re.sub(r"\]", "_", g)
	g = re.sub(r"\[", "_", g)

	# Replace all other non-allowed characters with underscores
	newg = ""
	for char in g:
		if char not in goodchars:
			newg += "_"
		else:
			newg += char
	if newg:
		g = newg

	# Normalize case for specific words
	for word in words:
		a = re.search(r"_(" + word + ")_", g, re.IGNORECASE)
		if a:
			for inword in a.groups():
				g = re.sub(r"_" + inword + "_", "_" + word + "_", g)

	# Fix patterns: triples, doubles, and odd characters
	## triples
	g = re.sub(r"_\._", ".", g)
	g = re.sub(r"\._\.", "_", g)
	g = re.sub(r"-_-", "_", g)
	g = re.sub(r"_-_", "-", g)
	## doubles
	g = re.sub(r"\.\.", ".", g)
	g = re.sub(r"_\.", ".", g)
	g = re.sub(r"\._", ".", g)
	g = re.sub(r"-_", "", g)
	g = re.sub(r"_-", "-", g)
	## strange chars
	g = re.sub(r"\^", "_", g)
	g = re.sub(r",", "_", g)
	## rm extra underscore
	g = re.sub(r"__*", "_", g)
	g = re.sub(r"__*", "_", g)
	## ends and starts
	g = re.sub(r"_*$", "", g)
	g = re.sub(r"^_*", "", g)
	g = re.sub(r"^-*", "", g)
	g = re.sub(r"^\.*", "", g)

	# Ensure cleaned filename is valid
	if len(g) == 0:
		print("\033[31mERROR: {0}\033[0m".format(g))
		sys.exit(1)
	g = re.sub("_*$", "", g)

	return g


#==============
def moveName(f: str, g: str) -> str:
	"""
	Renames the file from `f` to `g`.
	"""
	if len(g) > 1 and f != g and os.path.exists(f):
		if os.path.exists(g) and f.lower() != g.lower():
			print("\033[31mError: {0} exists\033[0m".format(g))
		elif f.lower() == g.lower():
			print("\033[33mWarning: {0} exists\033[0m".format(g))
			print("{0} --> {1}".format(f, g))
			shutil.move(f, g + "2")
			time.sleep(0.01)
			shutil.move(g + "2", g)
		else:
			print("{0} --> {1}".format(f, g))
			shutil.move(f, g)
			time.sleep(0.01)
	return g

#==============
def cleanNames(fs: list) -> None:
	"""
	Cleans up filenames in the given list of files.
	"""
	for f in fs:
		if f == "__pycache__":
			continue
		if f.endswith(".app") or ".app/" in f:
			continue
		if f.endswith(".part") or f.endswith(".dtapart"):
			continue
		if f.endswith(".py"):
			continue
		if os.path.isfile(f + ".part"):
			continue
		if f.endswith(".aria2") or os.path.isfile(f + ".aria2"):
			continue
		if f.endswith(".crdownload"):
			continue
		g = cleanName(f)
		moveName(f, g)

#==============
def rmSpaces(depth: int = 1) -> None:
	"""
	Recursively cleans up filenames in the current directory up to the specified depth.
	"""
	searchstr = "*"
	for i in range(depth):
		try:
			fs = glob.glob(str(searchstr))
		except:
			print(searchstr)
			fs = glob.glob(searchstr)
		cleanNames(fs)
		searchstr += "/*"

#======================
if __name__ == "__main__":
	depth = 4
	if len(sys.argv) > 1:
		f = sys.argv[1]
		g = cleanName(f)
		if not re.search("^[0-9]$", g):
			print("single file mode")
			moveName(f, g)
			sys.exit(1)
		depth = int(g)
	print("search mode")
	time.sleep(1.5)
	rmSpaces(depth)
