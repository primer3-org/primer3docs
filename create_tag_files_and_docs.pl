#!/usr/bin/perl -w

# Copyright (c) 1996,1997,1998,1999,2000,2001,2004,2006,2007,2008
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

my $scriptP3Version = "2.2.3";
my $scriptP3Years = "1996,1997,1998,1999,2000,2001,2004,2006,2007,2008,2009,2010";

# Modify here the order of the textblocks or add new:
my @textblocksOrder = (
"copyrightLicense",
"introduction",
"citationRequest",
"licenseExplain",
"installLinux",
"installMac",
"installWindows",
"buildOsX",
"systemRequirements",
"invokingPrimer3",
"commandLineTags",
"inputOutputConventions",
"example",
"migrateTags",
"sequenceTags",
"globalTags",
"programTags",
"calculatePenalties",
"fileFormat",
"outputTags",
"exampleOutput",
"pickAdvice",
"cautions",
"findNoPrimers",
"earlierVersions",
"exitStatusCodes",
"webInterface",
"acknowledgments");

# Modify here the order of the textblocks for the primer3web help page:
my @textblocksPrimer3WebHelp = (
"copyrightLicense",
"introduction",
"citationRequest",
"pickAdvice",
"cautions",
"findNoPrimers",
"sequenceTags",
"globalTags",
"outputHelp",
"providedMisprimingLibs",
"calculatePenalties",
"webInterface",
"acknowledgments");

# Modify here the order of the textblocks for the primer3plus help page:
my @textblocksPrimer3PlusHelp = (
"copyrightLicenseP3P",
"introduction",
"citationRequestP3P",
"pickAdvice",
"cautions",
"findNoPrimers",
"sequenceTags",
"globalTags",
"outputTags",
"providedMisprimingLibs",
"calculatePenalties",
"webInterface",
"acknowledgments");
#####################################################################


my $output_folder = cwd.'/script_output/';

print"start processing\n";

# Open the input Tag file
my $tagFile = "primer3_input_tags.xml";
my $tagRoot = getXmlRoot($tagFile);
# Read all Tag in an array
my @xml_tags = $tagRoot->getElementsByTagName('tag');
# First sort the tags alphabetically tags
my @sortedTags = sort tagSort @xml_tags;
# Print a message about the Tags
my $readTagCount = $#sortedTags + 1;
print "Read in $readTagCount input Tags for processing...\n";


# Open the comad line Tag file
my $commandFile = "primer3_command_line.xml";
my $commandRoot = getXmlRoot($commandFile);
# Read all Tag in an array
my @commandTags = $commandRoot->getElementsByTagName('tag');
# Print a message about the Tags
$readTagCount = $#commandTags + 1;
print "Read in $readTagCount command line Tags for processing...\n";


# Open the output Tag file
my $outTagFile = "primer3_output_tags.xml";
my $outTagRoot = getXmlRoot($outTagFile);
# Read all Tag in an array
my @outTagTags = $outTagRoot->getElementsByTagName('tag');
# Print a message about the Tags
$readTagCount = $#outTagTags + 1;
print "Read in $readTagCount output Tags for processing...\n";


# Open the TextBlocks file
my $textblocksFile = "primer3_textblocks.xml";
my $textblocksRoot = getXmlRoot($textblocksFile);
# Read all Tag in an array
my @textblocksTags = $textblocksRoot->getElementsByTagName('textBlock');
# Now read everything into two hashes
my %textHead;
my %textBody;
foreach my $idHolder (@textblocksTags) {
	my $id = get_node_content($idHolder, "id");
	$textHead{$id} = get_node_content($idHolder, "head");
	$textBody{$id} = get_node_content($idHolder, "text");
}

# Print a message about the TextBlocks
my $readtextblocksCount = $#textblocksTags + 1;
print "Read in $readtextblocksCount textblocks for processing...\n";





print "\n";

# Create the primer3_manual.txt
createReadmeTxt();

# Create the tag_definitions.xml
createTagDefinitionsXml();

# Create the primer3_manual.htm
createReadmeHtml();

# Create the primer3web_help.htm
createPrimer3webHelp();

# Create the primer3plusHelp.cgi
createPrimer3PlusHelp();

# Create the tags_list.txt
createTagList();


print"end processing\n";





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

##################################################
# sorts the tags alphabetically #
##################################################
sub tagSort {
	my $first = get_node_content($a, "tagName");
	my $second = get_node_content($b, "tagName");
	uc($first) cmp uc($second);
}

##################################################
# returns the html for the content of plain_page #
##################################################
sub get_node_content {
	my $root = shift;
	my $node = shift;
	
	my @xml = $root->getElementsByTagName($node);

	my $txt;
	
	if (!(defined ($xml[0]))) {
		$txt = "";
		return $txt;
	}

	$txt = $xml[0]->textContent();
	
	$txt =~ s/^\s+//;
	$txt =~ s/\s+$//;
	
	return $txt;
}

##################################################
# returns the html for the content of plain_page #
##################################################
sub get_node_content_array {
	my $root = shift;
	my $node = shift;
	
	my @xml = $root->getElementsByTagName($node);

	my @array;
	
	if (!(defined ($xml[0]))) {
		$array[0] = "";
		return @array;
	}
	my $i = 0;
	while (defined ($xml[$i])) {
		$array[$i] = $xml[$i]->textContent();
		$i++;
	}

	return @array;
}


##########################################
# Writes a string int a File and returns #
#      0 for success                     #
#      or error message                  #
##########################################
sub string2file {
	my $file = shift;	# File Name
	my $string = shift; # String to save in
	my $error = 0;
	
	if (open FILE, ">:utf8", $file) { 
		print FILE $string;
		close(FILE);
		
	} 
	else {
		$error = "Couldn't open $file for writing!\n";
	}

    return $error;
}


###############################
# creates the readme txt file #
###############################
sub createReadmeTxt {
	# Prepare the strings for the files
	my $txt_string = underlineText("primer3 release $scriptP3Version","=");
	$txt_string .= "\n";

# Create a Index
	$txt_string .= underlineText("Contents","=")."\n";
	my $chapterCount = 0;
	foreach my $textblock_holder (@textblocksOrder) {
		if ($textHead{$textblock_holder} ne ""){
			$chapterCount++;
			$txt_string .= "$chapterCount. $textHead{$textblock_holder}\n";
		}
	}
	$txt_string .= "\n\n";

	$chapterCount = 0;
	foreach my $textblock_holder (@textblocksOrder) {
		if ($textHead{$textblock_holder} ne ""){
		$chapterCount++;
			$txt_string .= underlineText("$chapterCount. $textHead{$textblock_holder}","=");
			$txt_string .= "$textBody{$textblock_holder}\n\n\n";
		}
		# Print out the command line tags at the right spot
		if ($textblock_holder eq "commandLineTags") {
			$txt_string =~ s/\n$//;
			foreach my $tag_holder (@commandTags) {
				# Get all the XML data of one tag
				my $tagName = get_node_content($tag_holder, "tagName");
				my $description = get_node_content($tag_holder, "description");
				
				# Assemble the txt file
				$txt_string .= $tagName."\n";
				$txt_string .= "   $description\n\n";
			}
			$txt_string .= "\n";
		}
		if ($textblock_holder eq "sequenceTags") {
			$txt_string =~ s/\n$//;
			$txt_string .= printTags("SEQUENCE_");
		}
		if ($textblock_holder eq "globalTags") {
			$txt_string =~ s/\n$//;
			$txt_string .= printTags("PRIMER_");
		}
		if ($textblock_holder eq "programTags") {
			$txt_string =~ s/\n$//;
			$txt_string .= printTags("P3_");
		}
		if ($textblock_holder eq "outputTags") {
			$txt_string =~ s/\n$//;
			$txt_string .= printTags("output");
		}
	}
	
	# Replace HTML decorations
	$txt_string =~ s/&gt;/>/g;
	$txt_string =~ s/&lt;/</g;
	$txt_string =~ s/&quot;/\"/g;
	$txt_string =~ s/<a (.*?)>(.*?)<\/a>/$2/g;

	# Replace HTML decorations	
	$txt_string =~ s/<br \/>//g;
	$txt_string =~ s/<h3>//g;
	$txt_string =~ s/<\/h3>//g;
	$txt_string =~ s/<p>//g;
	$txt_string =~ s/<\/p>//g;
	$txt_string =~ s/<link>//g;
	$txt_string =~ s/<\/link>//g;
	$txt_string =~ s/<pre>//g;
	$txt_string =~ s/<\/pre>//g;
	$txt_string =~ s/<i>//g;
	$txt_string =~ s/<\/i>//g;
	$txt_string =~ s/<tt>//g;
	$txt_string =~ s/<\/tt>//g;
	$txt_string =~ s/<p3t>//g;
	$txt_string =~ s/<\/p3t>//g;
	

	# Write the files to the disk
	my $output_file = $output_folder. "primer3_manual.txt";
	string2file($output_file, $txt_string);

	return 0;
}


#########################################
# prints all tags of a certain group    #
# $text can limit the output to certain #
# tags, "output" prints all tags        #
#########################################
sub printTags {
	my $text = shift;
	my $output;
	my $tagCount = 0;
	my @tags;
	my $tagName;
	my $dataType;
	my $default;
	my $optional;
	my $description;

	if ($text eq "output"){
		@tags = @outTagTags;
	} else {
		@tags = @xml_tags;
	}
	# Now print out all tags
	foreach my $tag_holder (@tags) {
		# Get all the XML data of one tag
		my @tagsNames = get_node_content_array($tag_holder, "tagName");
		$dataType = get_node_content($tag_holder, "dataType");
		$default = get_node_content($tag_holder, "default");
		$optional = get_node_content($tag_holder, "optional");
		$description = get_node_content($tag_holder, "description");
		
		
		if (($tagsNames[0] =~ /^$text/) and ($text ne "output")) {
			foreach $tagName (@tagsNames) {
				$output .= "<h3><a name=\"$tagName\">".$tagName." (";
				$output .= $dataType."; default ".$default.")</a></h3>\n";
			}
			
			$tagCount++;
			
			# Assemble the txt file
			$output .= "\n$description\n\n\n";
		}

		if ($text eq "output") {
			foreach $tagName (@tagsNames) {
				# Assemble the txt file
				$output .= "<h3><a name=\"$tagName\">";
				$output .= $tagName."=".$dataType;
				if ($optional eq "Y"){
					$output .= " (*)";
				}
				$output .= "</a></h3>\n";
			}
			$tagCount++;
			
			# Assemble the txt file
			$output .= "\n$description\n\n\n";
		}
		
	}

	print "Printed $tagCount $text - Tags in readme.txt\n";
	
	return $output;
}


##############################
# underlines the text with - #
##############################
sub underlineText {
	my $text = shift;
	my $symbol = shift;
	my $output = "$text\n";
	$text =~ s/./$symbol/g;
	$output .= "$text\n";
	
	return $output;
}


##################################
# creates the tags_list.txt file #
##################################
sub createTagList {
	# Prepare the strings for the files
	my $xml_string = "my \@docTags = (";
	my $tagCount = 0;
	my ($oldTagName, $tagName);
	my $tag_difference = "New Tag   -  Old Tag\n";
    my $default_set = "Default Settings:\n\n";
    my $default_hash = "my %defaultSettings = (\n";
	my $dev_val;
		
	# Now print out all tags
	foreach my $tag_holder (@xml_tags) {
		$tagCount++;
		
		# Get all the XML data of one tag
		$tagName = get_node_content($tag_holder, "tagName");
		$dev_val = get_node_content($tag_holder, "default");
	
		# Assemble the XML file
		$xml_string .= "\"$tagName\",\n";
        $default_set .= "$tagName=$dev_val\n";
        $default_hash .= "  \"$tagName\"=>\"$dev_val\",\n";
	}
	
	# Finish the strings for the files
	$xml_string .= ");\n\n\n";
	
    $default_set .= "\n\n";

    $default_hash .= ");\n\n\n";
	
	$xml_string .= "my %docTags = (";
	
	# Now print out all tags
	foreach my $tag_holder (@xml_tags) {
		$tagCount++;
		
		# Get all the XML data of one tag
		$tagName = get_node_content($tag_holder, "tagName");
		my @oldTags = get_node_content_array($tag_holder, "oldTagName");
	
		# Assemble the XML file
		if (!($oldTags[0] eq "")) {
			foreach $oldTagName (@oldTags) {
				$xml_string .= "$oldTagName => \"$tagName\",\n";
				$tag_difference .= "$tagName   -  $oldTagName\n";
			}
		}
		$xml_string .= "$tagName => \"$tagName\",\n";
	
	}
	
	# Finish the strings for the files
	$xml_string .= ");\n\n\n";
	
	$xml_string .= $tag_difference;
	
    $xml_string .= "\n\n";
	
	$xml_string .= $default_set;
	
	$xml_string .= $default_hash;
	
	# Write the files to the disk
	my $output_file = $output_folder. "tags_list.txt";
	string2file($output_file, $xml_string);

	print "Printed $tagCount Tags in tags_list.txt\n";

	return 0;
}

########################################
# creates the tag_definitions.xml file #
########################################
sub createTagDefinitionsXml {
	# Prepare the strings for the files
	my $xml_string = qq{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<tagList version="1.0">
};
	my $tagCount = 0;
	
	# Now print out all tags
	foreach my $tag_holder (@xml_tags) {
		$tagCount++;
		
		# Get all the XML data of one tag
		my $tagName = get_node_content($tag_holder, "tagName");
		my $dataType = get_node_content($tag_holder, "dataType");
		my $default = get_node_content($tag_holder, "default");
		my $description = get_node_content($tag_holder, "description");
	
		# Assemble the XML file
		$xml_string .= "<tag>\n\t<tagName>".$tagName."</tagName>\n\t<dataType>";
		$xml_string .= $dataType."</dataType>\n\t<default>".$default;
		$xml_string .= "</default>\n\t<description>\n<![CDATA[";
		$xml_string .= $description."]]>\n\t</description>\n</tag>\n";
		
	}
	
	# Finish the strings for the files
	$xml_string .= "</tagList>\n";
	
	# Write the files to the disk
	my $output_file = $output_folder. "tag_definitions.xml";
	string2file($output_file, $xml_string);

	print "Printed $tagCount Tags in tag_definitions.xml\n";

	return 0;
}


###############################
# creates the readme.htm file #
###############################
sub createReadmeHtml {
	# Prepare the strings for the files
	my $html_string = html_get_header();

	# Create a main title
	$html_string .= "<h1>PRIMER3 RELEASE $scriptP3Version MANUAL</h1>\n";

	# Create a Index
	$html_string .= "<h2>CONTENTS</h2>";
	my $chapterCount = 0;
	$html_string .= "<p>\n";
	foreach my $textblock_holder (@textblocksOrder) {
		if ($textHead{$textblock_holder} ne ""){
			$chapterCount++;
			$html_string .= "<a href=\"#$textblock_holder\">";
			$html_string .= "$chapterCount. $textHead{$textblock_holder}</a><br />\n";
		}
	}
	$html_string .= "</p>\n";

	$chapterCount = 0;
	foreach my $textblock_holder (@textblocksOrder) {
		if ($textHead{$textblock_holder} ne ""){
			$chapterCount++;		
			$html_string .= "<h2><a name=\"$textblock_holder\">$chapterCount. ";
			$html_string .= "$textHead{$textblock_holder}</a></h2>\n\n";
			$html_string .= "$textBody{$textblock_holder}\n\n";
		}
		# Print out the command line tags at the right spot
		if ($textblock_holder eq "commandLineTags") {
			$html_string =~ s/\n$//;
			foreach my $tag_holder (@commandTags) {
				# Get all the XML data of one tag
				my $tagName = get_node_content($tag_holder, "tagName");
				my $description = get_node_content($tag_holder, "description");
				
				# Assemble the txt file
				$html_string .= "<h3>$tagName</h3>\n";
				$html_string .= "$description\n\n";
			}
			$html_string .= "\n";
		}
		if ($textblock_holder eq "sequenceTags") {
			$html_string =~ s/\n$//;
			$html_string .= printTable("SEQUENCE_");
			$html_string .= printTags("SEQUENCE_");
		}
		if ($textblock_holder eq "globalTags") {
			$html_string =~ s/\n$//;
			$html_string .= printTable("PRIMER_");
			$html_string .= printTags("PRIMER_");
		}
		if ($textblock_holder eq "programTags") {
			$html_string =~ s/\n$//;
			$html_string .= printTags("P3_");
		}
		if ($textblock_holder eq "outputTags") {
			$html_string =~ s/\n$//;
			$html_string .= printTags("output");
		}
	}
	
	# Finish the strings for the files
	$html_string .= html_get_footer();
	
	$html_string =~ s/<br \/>/<br>/g;
	$html_string =~ s/<link>(.*?)<\/link>/<a href=\"$1\">$1<\/a>/g;
	$html_string =~ s/<p3t>(.*?)<\/p3t>/<a href=\"#$1\">$1<\/a>/g;
	
	# Write the files to the disk
	my $output_file = $output_folder. "primer3_manual.htm";
	string2file($output_file, $html_string);

	return 0;
}

########################################
# creates the primer3web_help.htm file #
########################################
sub createPrimer3webHelp {
    # Prepare the strings for the files
    my $html_string = html_get_header();

    $html_string .= "\n\n<!-- This file was created by the documentation scripts -->\n";
    $html_string .= "<!-- Do not edit this file -->\n";
    $html_string .= "<!-- Edit the documentation XMLs instead! -->\n\n\n";

    # Create a Index
    $html_string .= "<h2>Primer3web - Help</h2>";
    $html_string .= "<h2>Index of contents</h2>";
    my $chapterCount = 0;
    $html_string .= "<p>\n";
    foreach my $textblock_holder (@textblocksPrimer3WebHelp) {
        if ($textHead{$textblock_holder} ne ""){
            $chapterCount++;
            $html_string .= "<a href=\"#$textblock_holder\">";
            $html_string .= "$chapterCount. $textHead{$textblock_holder}</a><br />\n";
        }
    }
    $html_string .= "</p>\n";

    $chapterCount = 0;
    foreach my $textblock_holder (@textblocksPrimer3WebHelp) {
        if ($textHead{$textblock_holder} ne ""){
            $chapterCount++;        
            $html_string .= "<h2><a name=\"$textblock_holder\">$chapterCount. ";
            $html_string .= "$textHead{$textblock_holder}</a></h2>\n\n";
            $html_string .= "$textBody{$textblock_holder}\n\n";
        }
        # Print out the command line tags at the right spot
        if ($textblock_holder eq "commandLineTags") {
            $html_string =~ s/\n$//;
            foreach my $tag_holder (@commandTags) {
                # Get all the XML data of one tag
                my $tagName = get_node_content($tag_holder, "tagName");
                my $description = get_node_content($tag_holder, "description");
                
                # Assemble the txt file
                $html_string .= "<h3>$tagName</h3>\n";
                $html_string .= "$description\n\n";
            }
            $html_string .= "\n";
        }
        if ($textblock_holder eq "sequenceTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTable("SEQUENCE_");
            $html_string .= printTags("SEQUENCE_");
        }
        if ($textblock_holder eq "globalTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTable("PRIMER_");
            $html_string .= printTags("PRIMER_");
        }
        if ($textblock_holder eq "programTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTags("P3_");
        }
        if ($textblock_holder eq "outputTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTags("output");
        }
    }
    
    # Finish the strings for the files
    $html_string .= html_get_footer();
    
    $html_string =~ s/<br \/>/<br>/g;
    $html_string =~ s/<link>(.*?)<\/link>/<a href=\"$1\">$1<\/a>/g;
    $html_string =~ s/<p3t>(.*?)<\/p3t>/<a href=\"#$1\">$1<\/a>/g;
    
    # Write the files to the disk
    my $output_file = $output_folder. "primer3web_help.htm";
    string2file($output_file, $html_string);

    return 0;
}

########################################
# creates the primer3plusHelp.cgi file #
########################################
sub createPrimer3PlusHelp {
    # Prepare the strings for the files
    my $final_html_string = cgi_get_header();


    # Create a Index
    my $html_string .= "<h2>Index of contents</h2>";
    my $chapterCount = 0;
    $html_string .= "<p>\n";
    foreach my $textblock_holder (@textblocksPrimer3WebHelp) {
        if ($textHead{$textblock_holder} ne ""){
            $chapterCount++;
            $html_string .= "<a href=\"#$textblock_holder\">";
            $html_string .= "$chapterCount. $textHead{$textblock_holder}</a><br />\n";
        }
    }
    $html_string .= "</p>\n";

    $chapterCount = 0;
    foreach my $textblock_holder (@textblocksPrimer3PlusHelp) {
        if ($textHead{$textblock_holder} ne ""){
            $chapterCount++;        
            $html_string .= "<h2><a name=\"$textblock_holder\">$chapterCount. ";
            $html_string .= "$textHead{$textblock_holder}</a></h2>\n\n";
            $html_string .= "$textBody{$textblock_holder}\n\n";
        }
        # Print out the command line tags at the right spot
        if ($textblock_holder eq "commandLineTags") {
            $html_string =~ s/\n$//;
            foreach my $tag_holder (@commandTags) {
                # Get all the XML data of one tag
                my $tagName = get_node_content($tag_holder, "tagName");
                my $description = get_node_content($tag_holder, "description");
                
                # Assemble the txt file
                $html_string .= "<h3>$tagName</h3>\n";
                $html_string .= "$description\n\n";
            }
            $html_string .= "\n";
        }
        if ($textblock_holder eq "sequenceTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTable("SEQUENCE_");
            $html_string .= printTags("SEQUENCE_");
        }
        if ($textblock_holder eq "globalTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTable("PRIMER_");
            $html_string .= printTags("PRIMER_");
        }
        if ($textblock_holder eq "programTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTags("P3_");
        }
        if ($textblock_holder eq "outputTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTags("output");
        }
    }
    
    $html_string =~ s/<br \/>/<br>/g;
    $html_string =~ s/<link>(.*?)<\/link>/<a href=\"$1\">$1<\/a>/g;
    $html_string =~ s/<p3t>(.*?)<\/p3t>/<a href=\"#$1\">$1<\/a>/g;

    $final_html_string .= $html_string;
    
    # Finish the strings for the files
    $final_html_string .= cgi_get_footer();

    # Write the files to the disk
    my $output_file = $output_folder. "primer3plusHelp.cgi";
    string2file($output_file, $final_html_string);

    return 0;
}

####################################################
# prints a table of all tags of a certain group    #
# $text can limit the output to certain            #
# tags, "output" prints all tags                   #
####################################################
sub printTable {
	my $text = shift;
	my $output = "<table style=\"text-align: left; width: 800px;\" border=\"1\">\n";

	my $tagCount = 0;
	my @tags;
	my @to_use_tags;
	my $tagName;

	if ($text eq "output"){
		@tags = @outTagTags;
	} else {
		@tags = @xml_tags;
	}
	# Now read in all tags for the table
	foreach my $tag_holder (@tags) {
		# Get all the XML data of one tag
		my @tagsNames = get_node_content_array($tag_holder, "tagName");
		
		if (($tagsNames[0] =~ /^$text/) and ($text ne "output")) {
			foreach $tagName (@tagsNames) {
				$tagCount++;
				push (@to_use_tags, "$tagName");
			}
		}

		if ($text eq "output") {
			foreach $tagName (@tagsNames) {
				$tagCount++;
				push (@to_use_tags, "$tagName");
			}
		}
		
	}
	my @sort_use_tags = sort(@to_use_tags);
	my $fields = $#to_use_tags + 1;
	my $columns = int(($fields / 3)+0.7);
	
	my ($a, $b, $c);
	
	for (my $i=1 ; $i < $columns + 1 ; $i++ ) {
		$a = $i - 1;
		$b = $columns + $i - 1;
		$c = 2*$columns + $i - 1;
		$output .= "	  <tr>\n";
		if (defined($sort_use_tags[$a])){
			$output .= "	    <td><a href=\"#$sort_use_tags[$a]\">$sort_use_tags[$a]<\/a></td>\n";		
		} else {
			$output .= "	    <td>&nbsp;</td>\n";		
			
		}
		if (defined($sort_use_tags[$b])){
			$output .= "	    <td><a href=\"#$sort_use_tags[$b]\">$sort_use_tags[$b]<\/a></td>\n";		
		} else {
			$output .= "	    <td>&nbsp;</td>\n";		
			
		}
		if (defined($sort_use_tags[$c])){
			$output .= "	    <td><a href=\"#$sort_use_tags[$c]\">$sort_use_tags[$c]<\/a></td>\n";		
		} else {
			$output .= "	    <td>&nbsp;</td>\n";		
			
		}
		$output .= "	  </tr>\n";
	}
	
	$output .= "</table>\n";

	print "Printed $tagCount in $text - Table\n";
	
	return $output;
}


###################################
# returns the html for the header #
# opens <html> <body> <div page>  #
###################################
sub html_get_header {
	my $html = qq{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>primer3 release $scriptP3Version - manual</title>
  <style type="text/css">
  body {
  background-color:white;
  color:black;
  font-size:100.01%;
  margin:0;
  min-width:41em;
  padding:5px;
  text-align:left;
  }
  td {
  font-size:0.78em;
  }
  h2 {
  padding-top:1.2em;
  }
  h3 {
  padding-top:1.2em;
  }
  div#page {
  background:#FFFFFF;
  margin:25px;
  padding:0;
  text-align:left;
  width:850px;
  }
  </style>
</head>
<body>
<div id="page">
};

	return $html;
}

###################################
# returns the html for the footer #
# closes <div page> <body> <html> #
###################################
sub html_get_footer {
    my $html =
    qq{</div>
</body>
</html>
};
    
    return $html;
}

##########################
# returns the cgi header #
##########################
sub cgi_get_header {
    my $html = qq{#!/usr/bin/perl

#  Copyright (c) 2006, 2007
#  by Andreas Untergasser and Harm Nijveen
#  All rights reserved.
# 
#  This file is part of Primer3Plus. Primer3Plus is a webinterface to primer3.
# 
#  The Primer3Plus is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
# 
#  Primer3Plus is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with Primer3Plus (file gpl.txt in the source distribution);
#  if not, write to the Free Software Foundation, Inc., 51 Franklin St,
#  Fifth Floor, Boston, MA  02110-1301  USA

use strict;
use HtmlFunctions;

# This CGI prints out the Help-File 

# This file was created by the documentation scripts
# Do not edit this file
# Edit the documentation XMLs instead!


my \$helpHTML = qq};
$html .= "{\n";
$html .= qq{<div id="primer3plus_help">

};

    return $html;
}

##########################
# returns the cgi footer #
##########################
sub cgi_get_footer {
	my $html = "</div>\n";
    $html .= "};";
    $html .= qq{

print "Content-type: text/html\\n\\n";
print createHelpHTML(\$helpHTML), "\\n";

};
	
	return $html;
}

