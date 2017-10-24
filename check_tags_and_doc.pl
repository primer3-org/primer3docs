#!/usr/bin/perl -w

# Copyright (c) 1996,1997,1998,1999,2000,2001,2004,2006,2007,2008,2009,2010
#               2011,2012,2016
# Whitehead Institute for Biomedical Research, Steve Rozen
# (http://purl.com/STEVEROZEN/), Andreas Untergasser and Helen Skaletsky.
# All rights reserved.
# 
#     This file is part of the primer3 suite and libraries.
# 
#     The primer3 suite and libraries are free software;
#     you can redistribute them and/or modify them under the terms
#     of the GNU General Public License as published by the Free
#     Software Foundation; either version 2 of the License, or (at
#     your option) any later version.
# 
#     This software is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this software (file gpl-2.0.txt in the source
#     distribution); if not, write to the Free Software
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# This script requires the XML-LibXML extentions by Christian Glahn from cpan

use strict;
use Cwd;
use XML::LibXML;
use File::Copy;


#####################################################################
# Modify here the version and years:                                #

print"start processing\n";
my %docTags;

# Open the input Tag file
my $tagFile = "primer3_input_tags.xml";
my $tagRoot = getXmlRoot($tagFile);
# Read all Tag in an array
my @xml_tags = $tagRoot->getElementsByTagName('tagName');
foreach (@xml_tags) {
    $docTags{$_->firstChild->data} = 1;
}

# Open the comad line Tag file
my $commandFile = "primer3_command_line.xml";
my $commandRoot = getXmlRoot($commandFile);
# Read all Tag in an array
my @commandTags = $commandRoot->getElementsByTagName('tagName');
foreach (@commandTags) {
    $docTags{$_->firstChild->data} = 1;
}

# Open the output Tag file
my $outTagFile = "primer3_output_tags.xml";
my $outTagRoot = getXmlRoot($outTagFile);
# Read all Tag in an array
my @outTagTags = $outTagRoot->getElementsByTagName('tagName');

# Read in read_boulder.c
my $readBoulder = "";
if (open FILE, "<../read_boulder.c") {
    while(<FILE>) {
        $readBoulder .= $_;
    } 
    close(FILE);
}
else {
    print "Couldn't open ../read_boulder.c for reading!\n";
}

my @rawBoulder = split("\n", $readBoulder);
my %boulderTags;

foreach (@rawBoulder) {
    if ($_ =~ /COMPARE[^"]+"[^"]+"/) {
        $_ =~ s/^[^"]+"//;
        $_ =~ s/".+$//;
        $boulderTags{$_} = 1;
    }
}


# Check for new tags
my @prAr = sort(keys(%docTags));
foreach (@prAr) {
    if (!(defined $boulderTags{$_})) {
        print "Tag not read by primer3: $_\n";
    }
}

@prAr = sort(keys(%boulderTags));
foreach (@prAr) {
    if (!(defined $docTags{$_}) && ($_ ne "SEQUENCE")) {
        print "Tag missing in Docs: $_\n";
    }
}



###########################################
# Opent the xml file and returns the root #
###########################################
sub getXmlRoot {
	my $file = shift;
	
	# Open the xml File
	my $parser = XML::LibXML->new();
	my $tree = $parser->parse_file($file);
	my $root = $tree->getDocumentElement;
	
	# Get the root element name
	my $rootName = $root->nodeName;
	
	# Check the root element to be sure to have the right file
	if ($rootName ne "primer3Doc") {
		print "Error: $rootName of $file is not \"primer3Doc\"\n";
		exit;
	}
	return $root;
}

