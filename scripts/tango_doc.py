#!/usr/bin/python
# -*- coding: utf-8 -*-
# Author: Aziz Köksal
import os, re
from path import Path
from common import *

def copy_files(DATA, KANDIL, TANGO_DIR, DEST):
  """ Copies required files to the destination folder. """
  for FILE, DIR in (
      (TANGO_DIR/"LICENSE", DEST/"License.txt"), # Tango's license.
      (DATA/"html.css", DEST.HTMLSRC),
      (KANDIL.style,    DEST.CSS)):
    FILE.copy(DIR)
  for FILE in KANDIL.jsfiles:
    FILE.copy(DEST.JS)
  for img in KANDIL.images:
    img.copy(DEST.IMG)

def get_tango_version(path):
  for line in open(path):
    m = re.search("Major\s*=\s*(\d+)", line)
    if m: major = int(m.group(1))
    m = re.search("Minor\s*=\s*(\d+)", line)
    if m: minor = int(m.group(1))
  return "%s.%s.%s" % (major, minor/10, minor%10)

def write_tango_ddoc(path, revision):
  revision = "?rev=" + revision if revision != None else ''
  open(path, "w").write("""
LICENSE = see $(LINK2 http://www.dsource.org/projects/tango/wiki/LibraryLicense, license.txt)
REPOFILE = http://www.dsource.org/projects/tango/browser/trunk/$(DIL_MODPATH)%s
CODEURL =
MEMBERTABLE = <table>$0</table>
ANCHOR = <a name="$0"></a>
LP = (
RP = )
LB = [
RB = ]
SQRT = √
NAN = NaN
SUP = <sup>$0</sup>
BR = <br/>""" % revision
  )

def main():
  from optparse import OptionParser

  usage = "Usage: scripts/tango_doc.py TANGO_DIR [DESTINATION_DIR]"
  parser = OptionParser(usage=usage)
  parser.add_option("--rev", dest="revision", metavar="REVISION", default=None,
    type="int", help="set the repository REVISION to use in symbol links")
  parser.add_option("--zip", dest="zip", default=False, action="store_true",
    help="create a 7z archive")

  (options, args) = parser.parse_args()

  if len(args) < 1:
    return parser.print_help()

  # Path to the executable of dil.
  DIL_EXE   = Path("bin")/"dil"
  # The version of Tango we're dealing with.
  VERSION   = ""
  # Root of the Tango source code (from SVN.)
  TANGO_DIR = Path(args[0])
  # The source code folder of Tango.
  TANGO_SRC = TANGO_DIR/"tango"
  # Destination of doc files.
  DEST      = Path(firstof(str, getitem(args, 1), 'tangodoc'))
  # The JavaScript folder.
  DEST.JS, DEST.CSS, DEST.IMG = DEST//("js", "css", "img")
  # Destination of syntax highlighted source files.
  DEST.HTMLSRC = DEST/"htmlsrc"
  # Dil's data/ directory.
  DATA      = Path('data')
  # Dil's fancy documentation format.
  KANDIL    = get_kandil_path()
  # Temporary directory, deleted in the end.
  TMP       = DEST/"tmp"
  # Some DDoc macros for Tango.
  TANGO_DDOC= TMP/"tango.ddoc"
  # The list of module files (with info) that have been processed.
  MODLIST   = TMP/"modules.txt"
  # The files to generate documentation for.
  FILES     = []

  build_dil_if_inexistant(DIL_EXE)

  if not TANGO_DIR.exists:
    print "The path '%s' doesn't exist." % TANGO_DIR
    return

  VERSION = get_tango_version(TANGO_SRC/"core"/"Version.d")

  # Create directories.
  DEST.makedirs()
  map(Path.mkdir, (DEST.HTMLSRC, DEST.JS, DEST.CSS, DEST.IMG, TMP))

  find_source_files(TANGO_SRC, FILES)

  write_tango_ddoc(TANGO_DDOC, options.revision)
  DOC_FILES = [KANDIL/"kandil.ddoc", TANGO_DDOC] + FILES
  versions = ["Windows", "Tango", "DDoc"]
  generate_docs(DIL_EXE, DEST, MODLIST, DOC_FILES,
                versions, options=['-v', '-hl', '--kandil'])

  copy_files(DATA, KANDIL, TANGO_DIR, DEST)

  TMP.rmtree()

  if options.zip:
    name, src = "Tango.%s_doc" % VERSION, DEST
    cmd = "7zr a %(name)s.7z %(src)s" % locals()
    print cmd
    os.system(cmd)

if __name__ == "__main__":
  main()
