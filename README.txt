primer3 release 1.1.2
---------------------

Copyright (c) 1996,1997,1998,1999,2000,2001,2004,2006,2007
Whitehead Institute for Biomedical Research, Steve Rozen
(http://jura.wi.mit.edu/rozen), and Helen Skaletsky
All rights reserved.

Most of primer3 is released under the following _new_ BSD license:

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

   * Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following disclaimer
in the documentation and/or other materials provided with the
distribution.
   * Neither the names of the copyright holders nor contributors may
be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The oligtm library and tests are released under the GPL.  See
file src/gpl.txt or go to http://www.gnu.org/licenses/gpl.txt.

INTRODUCTION
------------
Primer3 picks primers for PCR reactions, considering as criteria:

o oligonucleotide melting temperature, size, GC content,
  and primer-dimer possibilities,

o PCR product size,

o positional constraints within the source (template) sequence, and

o possibilities for ectopic priming (amplifying the wrong sequence)

o many other constraints.

All of these criteria are user-specifiable as constraints, and
some are specifiable as terms in an objective function that
characterizes an optimal primer pair.

Whitehead Institute for Biomedical Research provides a web-based
front end to primer3 at
http://fokker.wi.mit.edu/cgi-bin/primer3/primer3_www.cgi


CITING PRIMER3
--------------
We request but do not require that use of this software be cited in
publications as

Steve Rozen and Helen J. Skaletsky (2000) Primer3 on the WWW for
general users and for biologist programmers.
In: Krawetz S, Misener S (eds) Bioinformatics Methods and
Protocols: Methods in Molecular Biology.  Humana Press, Totowa,
NJ, pp 365-386
Source code available at http://sourceforge.net/projects/primer3/

The paper above is available at
http://jura.wi.mit.edu/rozen/papers/rozen-and-skaletsky-2000-primer3.pdf


REPORTING BUGS AND PROBLEMS AND SUGGESTING ENHANCEMENTS
-------------------------------------------------------

For error reports or requests for enhancements, please send e-mail
to primer3-mail (at) lists.sourceforge.net after replacing (at)
with @.


INSTALLATION INSTRUCTIONS
-------------------------
Unzip and untar the distribution.

DO NOT do this on a PC -- primer3_core will not compile if pc
newlines get inserted into the source files.  Instead, move the
distribution (primer3_<release>.tar.gz) to Unix, and then

$ unzip primer3-<release number>.tar.gz
$ tar xvf primer3-<release number>.tar
$ cd primer3-<release number>/src

If you do not use gcc, modify the makefile to
  use your (ANSI) C compiler and appropriate 
  compile and link flags.

$ make all

# Warnings about pr_release being unused are harmless.
# You should have created executables primer3_core, ntdpal,
#  olgotm, and long_seq_tm_test

$ make test

# You should not see 'FAILED' during the tests.

If your perl command is not called perl (for example, if it is
called perl5) you will have to modify the 
Makefile in the test/ directory.

ntdpal (NucleoTide Dynamic Programming ALignment) is a
stand-alone program that provides primer3's alignment
functionality (local, a.k.a. Smith-Waterman, global,
a.k.a. Needleman-Wunsch, plus "half global").  It is provided
strictly as is; for further documentation please see the code.

BUILDING OSX UNIVERSAL BINARY
-----------------------------

** To build a processor-native, non-universal binary of primer3, 
the following is unneccesary**.  

The instructions above should be sufficient.

A pre-compiled, universal binary download for OSX is available from 
http://sourceforge.net/projects/primer3/ for the current release.

These instructions assume you want to build binaries compatible 
with *both* of the current processor architectures used by the Apple
platform (i,e. the binaries will be run on both PPC and intel platforms).

Provided you have the OS X developer tools installed
(you can download from http://developer.apple.com after
registering for a free account), you can compile a universal
build (intel and PPC native) of primer3.

FOR OS X 10.4 (TIGER)
-----------------------------
o you must be running OS X 10.4.x and should have the most
	recent version of XCode
o then run `make -f Makefile.OSX.Tiger all`
o run the tests as directed above

FOR OS X 10.5 (LEOPARD)
-----------------------------
o you must be running OS X 10.5.x and should have the most
	recent version of XCode
o then run `make -f Makefile.OSX.Leopard all`
o run the tests as directed above

Additional instructions for 'installing' the binaries may be found in
the README.OSX.txt.

You should be able to compile a 3-way binary which includes PPC64 support 
(intel, PPC, PPC64) by adding the `-arch ppc64` flag to the 
end of both the CFLAGS and LDFLAGS lines at the top of Makefile.OSX.`platform`  
This has not been tested.

SYSTEM REQUIREMENTS
-------------------

Please see http://sourceforge.net/projects/primer3/ for up-to-date
information.  Primer3 should compile on any Linux/Unix system
including MacOS 10 and on other systems with POSIX C
(e.g. MSWindows).  The Makefile may need to be modified for
compilation with C compilers other than gcc.  Our hope is to
distribute binarie for SourceForge in the near future.  Primer3
still uses many Kernighan-&-Richie-style function headers, so
you might have to force your compiler to accept them.


INVOKING primer3_core
---------------------

By default, the executable program produced by the Makefile is
called primer3_core.  This is the C program that does the heavy
lifting of primer picking.  There is also a more user-friendly
web interface (distributed separately).

The command line for primer3 is:

primer3_core [ -format_output ] [ -strict_tags ] < input_file.txt

-format_output indicates that primer3_core should generate
   user-oriented (rather than program-oriented) output.

-strict_tags indicates that primer3_core should generate
   a fatal error if there is any tag in the input that
   it does not recognize (see INPUT AND OUTPUT CONVENTIONS).

WARNING: primer3_core only reads its input on stdin, so the usual
unix convention of

primer3_core input_file.txt

*will not work*.  Primer3_core will just sit there forever
waiting for its input on stdin.

Note: The old flag -2x_compat is no longer supported.


INPUT AND OUTPUT CONVENTIONS
----------------------------

By default, primer3 accepts input in Boulder-io format, a
pre-XML, pre-RDF, text-based input/output format for
program-to-program data interchange.  By default, primer3 also
produces output in the same format.  

When run with the -format_output command-line flag, primer3
prints a more user-oriented report for each sequence.

Primer3 exits with 0 status if it operates correctly.  See EXIT
STATUS CODES below for additional information.

The syntax of the version of Boulder-io recognized by primer3 is
as follows:

  o Input consists of a sequence of RECORDs.

  o A RECORD consists of a sequence of (TAG,VALUE) pairs, each terminated
    by a newline character (\n). A RECORD is terminated by  '='
    appearing by itself on a line.

  o A (TAG,VALUE) pair has the following requirements:

        o the TAG must be immediately (without spaces) 
          followed by '='.
	o the pair must be terminated by a newline character.

An example of a legal (TAG,VALUE) pair is

SEQUENCE_ID=my_marker

and an example of a BOULDER-IO record is

SEQUENCE_ID=test1
SEQUENCE_DNA=GACTGATCGATGCTAGCTACGATCGATCGATGCATGCTAGCTAGCTAGCTGCTAGC
=

Many records can be sent, one after another. Below is an example
of three different records which might be passed through a
boulder-io stream:

SEQUENCE_ID=test1
SEQUENCE_DNA=GACTGATCGATGCTAGCTACGATCGATCGATGCATGCTAGCTAGCTAGCTGCTAGC
=
SEQUENCE_ID=test2
SEQUENCE_DNA=CATCATCATCATCGATGCTAGCATCNNACGTACGANCANATGCATCGATCGT
=
SEQUENCE_ID=test3
SEQUENCE_DNA=NACGTAGCTAGCATGCACNACTCGACNACGATGCACNACAGCTGCATCGATGC
=

Primer3 reads boulder-io on stdin and echos its input and returns
results in boulder-io format on stdout.  Primer3 indicates many
user-correctable errors by a value in the PRIMER_ERROR tag (see
below) and indicates other errors, including system configuration
errors, resource errors (such out-of-memory errors), and detected
programming errors by a message on stderr and a non-zero exit
status.

Below is the list of input tags that primer3 recognizes.
Primer3 echos and ignores any tags it does not recognize, unless
the -strict_tags flag is set on the command line, in which case
primer3 prints an error in the PRIMER_ERROR output tag (see
below), and prints additional information on stdout; this option
can be useful for debugging systems that incorporate primer.

Except for tags with the type "interval list" each tag is allowed
only ONCE in any given input record.  This restriction is not
systematically checked in this beta release: use care.

There are 2 major classes of input tags.  "Sequence" input tags
describe a particular input sequence to primer3, and are reset
after every boulder record.  "Global" input tags describe the
general parameters that primer3 should use in its searches, and
the values of these tags persist between input boulder records
until or unless they are explicitly reset.  Errors in "Sequence"
input tags invalidate the current record, but primer3 will
continue to process additional records.  Errors in "Global" input
tags are fatal because they invalidate the basic conditions under
which primers are being picked.


ADVICE FOR PICKING PRIMERS
--------------------------
We suggest consulting: Wojciech Rychlik (1993) "Selection of
Primers for Polymerase Chain Reaction" in BA White, Ed., "Methods
in Molecular Biology, Vol. 15: PCR Protocols: Current Methods and
Applications", pp 31-40, Humana Press, Totowa NJ.


CAUTIONS
--------
Some of the most important issues in primer picking can be
addressed only before using primer3.  These are sequence quality
(including making sure the sequence is not vector and not
chimeric) and avoiding repetitive elements.

Techniques for avoiding problems include a thorough understanding
of possible vector contaminants and cloning artifacts coupled
with database searches using blast, fasta, or other similarity
searching program to screen for vector contaminants and possible
repeats.  Repbase (J. Jurka, A.F.A. Smit, C. Pethiyagoda, and
others, 1995-1996, ftp://ncbi.nlm.nih.gov/repository/repbase)
is an excellent source of repeat sequences and pointers to the
literature.  (The Repbase files need to be converted to Fasta format
before they can be used by primer3.) Primer3 now allows you to screen
candidate oligos against a Mispriming Library (or a Mishyb Library in
the case of internal oligos).


Sequence quality can be controlled by manual trace viewing and
quality clipping or automatic quality clipping programs.  Low-
quality bases should be changed to N's or can be made part of
Excluded Regions. The beginning of a sequencing read is often
problematic because of primer peaks, and the end of the read
often contains many low-quality or even meaningless called bases.
Therefore when picking primers from single-pass sequence it is
often best to use the INCLUDED_REGION parameter to ensure that
primer3 chooses primers in the high quality region of the read.

In addition, primer3 takes as input a Sequence Quality list for
use with those base calling programs 

(e.g. Phred, Bass/Grace, Trout) that output this information.


WHAT TO DO IF PRIMER3 CANNOT FIND ANY PRIMERS?
----------------------------------------------
Try relaxing various parameters, including the
self-complementarity parameters and max and min oligo melting
temperatures.  For example, for very A-T-rich regions you might
have to increase maximum primer size or decrease minimum melting
temperature.  It is usually unwise to reduce the minimum primer
size if your template is complex (e.g. a mammalian genome), since
small primers are more likely to be non-specific.  Make sure that
there are adequate stretches of non-Ns in the regions in which
you wish to pick primers.  If necessary you can also allow an N
in your primer and use an oligo mixture containing all four bases
at that position.

Try setting the PRIMER_EXPLAIN_FLAG input tag.


DIFFERENCES FROM EARLIER VERSIONS
---------------------------------

See the file release_notes.txt in this directory.


EXIT STATUS CODES
-----------------

 0 on normal operation (including "per-sequence"
   user input errors)
-1 under the following conditions:
   illegal command-line arguments.
   unable to fflush stdout.
   unable to open (for writing and creating) a .for, .rev
     or .int file (probably due to a protection problem).
-2 on out-of-memory
-3 empty input
-4 error in a "Global" input tag (message printed on stdout
   along with other output).

Primer3 calls abort() and dumps core (if possible) if a
programming error is detected by an assertion violation.

SIGINT and SIGTERM are handled essentially as empty input, except
the signal received is returned as the exit status and printed to
stderr.

In all of the error cases above Primer3 prints a message to stderr.


THE PRIMER3 WWW INTERFACE
-----------------------------
This distribution does not contain the Primer3 WWW interface.
Web interface code is likely available at (or linked to from)
http://sourceforge.net/projects/primer3/.


ACKNOWLEDGMENTS
---------------

Initial development of Primer3 was funded by Howard Hughes Medical
Institute and by the National Institutes of Health, National Human
Genome Research Institute under grants R01-HG00257 (to David C. Page)
and P50-HG00098 (to Eric S. Lander).

Primer3 was originally written by Helen J. Skaletsky (Howard Hughes
Medical Institute, Whitehead Institute) and Steve Rozen (Whitehead
Institute/MIT Center for Genome Research), based on the design of
earlier versions: Primer 0.5 (Steve Lincoln, Mark Daly, and Eric
S. Lander) and Primer v2 (Richard Resnick).  This initial version of
this documentation was written by Richard Resnick and Steve Rozen, and
the original web interface was designed by Richard Resnick.  Lincoln
Stein championed the use of the Boulder-IO format and the idea of
making primer3 a software component.  In addition, among others, Ernst
Molitor, Carl Foeller, and James Bonfield contributed to the early
design of primer3. We also thank Centerline Software, Inc., for uses
of its TestCenter memory-error, -leak, and test-coverage checker,
which helped us discover and correct a number of otherwise latent
errors in Primer3.

Primer3 is now operating as open software development project hosted
on SourceForge, and we are working out how to acknowledge all who have
contributed to its enahancement.  Current active developers can be
found at http://sourceforge.net/projects/primer3/.
