#!/usr/bin/perl -w

# Copyright (c) 1996,1997,1998,1999,2000,2001,2004,2006,2007,2008,2009,2010
#               2011,2012,2016
# Whitehead Institute for Biomedical Research, Steve Rozen
# (http://purl.com/STEVEROZEN/), Andreas Untergasser and Helen Skaletsky.
# All rights reserved.
# 
#     This file is part of the Primer3 suite and libraries.
# 
#     The Primer3 suite and libraries are free software;
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
# cpan App::cpanminus
# sudo apt install cpanminus
# cpanm XML::LibXML
# reopen terminal

use strict;
use Cwd;
use XML::LibXML;
use File::Copy;


#####################################################################
# Modify here the version and years:                                #

my $scriptP3Version = "2.6.0";
my $scriptP3ManualTit = "PRIMER3 RELEASE $scriptP3Version MANUAL";
my $scriptP3PlusHelpTit = "PRIMER3PLUS RELEASE 3.2.0 HELP";
my $scriptP3WebHelpTit = "PRIMER3WEB RELEASE 4.1.0 MANUAL";

my $scriptP3Years =  "1996-2022", #"1996,1997,1998,1999,2000,2001,2004,2006,2007,2008,2009,2010,2011,2012,2013,2016";

# Modify here the order of the textblocks or add new:
my @textblocksOrder = (
"copyrightLicense",
"introduction",
"citationRequest",
"licenseExplain",
"differencePrimer3vsPrimer3Plus",
"changesFrom2.2.3",
"installLinux",
"installMac",
"installWindows",
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
"primerBinding",
"cautions",
"findNoPrimers",
"earlierVersions",
"exitStatusCodes",
"webInterface",
"acknowledgments");

# Modify here the order of the textblocks for the Primer3Web help page:
my @textblocksPrimer3WebHelp = (
"copyrightLicense",
"introduction",
"citationRequest",
"licenseExplain",
"sequenceTags",
"globalTags",
"outputHelp",
"calculatePenalties",
"cautions",
"providedMisprimingLibs",
"findNoPrimers",
"pickAdvice",
"primerBinding",
"webInterface",
"acknowledgments");

# Modify here the order of the textblocks for the Primer3Plus help page:
my @textblocksPrimer3PlusHelp = (
"copyrightLicense",
"introduction",
"citationRequest",
"licenseExplain",
"differencePrimer3vsPrimer3Plus",
"pickAdvice",
"primerBinding",
"cautions",
"findNoPrimers",
"sequenceTags",
"globalTags",
"p3pTags",
"outputTags",
"providedMisprimingLibs",
"calculatePenalties",
"webInterface",
"acknowledgments");
#####################################################################


my $output_folder = cwd.'/script_output/';
if (!(-d $output_folder)) {
    mkdir $output_folder;
    print "mkdir: $output_folder\n";
}

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


# Open the output Tag file
my $p3pTagFile = "primer3plus_tags.xml";
my $p3pTagRoot = getXmlRoot($p3pTagFile);
# Read all Tag in an array
my @p3pTagTags = $p3pTagRoot->getElementsByTagName('tag');
# First sort the tags alphabetically tags
my @sortedp3pTags = sort tagSort @p3pTagTags;
# Print a message about the Tags
$readTagCount = $#sortedp3pTags + 1;
print "Read in $readTagCount Primer3Plus Tags for processing...\n";


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
print "Read in $readtextblocksCount textblocks for processing...\n\n";

# Create the tag_definitions.xml
createTagDefinitionsXml();

# Create the primer3_manual.htm
createReadmeHtml();

# Create the primer3web_help.htm
createPrimer3webHelp();

# Create the tags_list.txt
createTagList();

###########################
# Change Settings for P3P #
###########################
changeP3PSettings();

# Create the primer3plusHelp.html
createPrimer3PlusHelp();

# Create the default_settings.json
createSettingsJson();

print"end processing\n";

###########################
# Change Settings for P3P #
###########################
sub changeP3PSettings() {
	my %upVal;
	$upVal{'PRIMER_PRODUCT_SIZE_RANGE'} = '501-600 601-700 401-500 701-850 851-1000 1001-1500 1501-3000 3001-5000 401-500 301-400 201-300 101-200 5001-7000 7001-10000 10001-20000';
	$upVal{'PRIMER_EXPLAIN_FLAG'} = '1';
	$upVal{'PRIMER_FIRST_BASE_INDEX'} = '1';
        $upVal{'PRIMER_SECONDARY_STRUCTURE_ALIGNMENT'} = '1';
        $upVal{'PRIMER_NUM_RETURN'} = '10';
	$upVal{'PRIMER_INTERNAL_MAX_HAIRPIN_TH'} = '47.00';
	$upVal{'PRIMER_LIBERAL_BASE'} = '1';
	$upVal{'PRIMER_MAX_END_STABILITY'} = '9.0';
	$upVal{'PRIMER_MAX_HAIRPIN_TH'} = '47.00';
	$upVal{'PRIMER_MAX_TEMPLATE_MISPRIMING'} = '12.00';
	$upVal{'PRIMER_MAX_TEMPLATE_MISPRIMING_TH'} = '47.00';
	$upVal{'PRIMER_MIN_LEFT_THREE_PRIME_DISTANCE'} = '3';
	$upVal{'PRIMER_MIN_RIGHT_THREE_PRIME_DISTANCE'} = '3';
	$upVal{'PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING'} = '24.00';
	$upVal{'PRIMER_PAIR_MAX_TEMPLATE_MISPRIMING_TH'} = '47.00';

	print "Replace default values for P3P:\nUpdate in textblocks differencePrimer3vsPrimer3Plus\n";
	my $p3_Vals = "Primer3 Values:\n";
	my $p3p_Vals = "Primer3Plus Values:\n";
        foreach my $tag_holder (@xml_tags) {
		my $tagName = get_node_content($tag_holder, "tagName");
                my $dev_val = get_node_content($tag_holder, "default");
		if(defined($upVal{$tagName})) {
			$p3_Vals .= "  " . $tagName . "=" . get_node_content($tag_holder, "default") . "\n";
			set_node_content($tag_holder, "default", $upVal{$tagName});
			$p3p_Vals .= "  " . $tagName . "=" . $upVal{$tagName} . "\n";
		}
	}
	print "$p3_Vals\n$p3p_Vals\n";
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
sub set_node_content {
        my $root = shift;
        my $node = shift;
	my $val  = shift;

        my @xml = $root->getElementsByTagName($node);

        if (!(defined ($xml[0]))) {
                return;
        }

        $xml[0]->removeChildNodes();
	$xml[0]->appendText($val);
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

	$string =~ s/\s+\n/\n/g;

	if (open FILE, ">:utf8", $file) { 
		print FILE $string;
		close(FILE);
		
	} 
	else {
		$error = "Couldn't open $file for writing!\n";
	}

    return $error;
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
        } elsif ($text eq "P3P_") {
                @tags = @p3pTagTags;
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
				$output .= "<h3><a id=\"$tagName\">".$tagName." (";
				$output .= $dataType."; default ".$default.")</a></h3>\n";
			}
			
			$tagCount++;
			
			# Assemble the txt file
			$output .= "\n$description\n\n\n";
		}

		if ($text eq "output") {
			foreach $tagName (@tagsNames) {
				# Assemble the txt file
				$output .= "<h3><a id=\"$tagName\">";
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

##########################################
# creates the default_settings.json file #
##########################################
sub createSettingsJson {
        # Prepare the strings for the files
        my $out_string = "{\"def\":{\n";
        my $tagCount = 0;
        my ($oldTagName, $tagName, $tagType);
        my $dev_val;

	# Add the Primer3Plus tags:
	my @combP3P = @xml_tags;
	push(@combP3P, @p3pTagTags);
        # First sort the tags alphabetically tags
        my @sortedComb = sort tagSort @combP3P;

        # Now print out all tags
        foreach my $tag_holder (@sortedComb) {
                $tagCount++;

                # Get all the XML data of one tag
                $tagName = get_node_content($tag_holder, "tagName");
		$tagType = get_node_content($tag_holder, "dataType");
                $dev_val = get_node_content($tag_holder, "default");
		if ($dev_val eq "empty") {
			$dev_val = "";
		}
		if ($tagType =~ /"/) {
			print "Alert Tag $tagName: in dataType invaldid\" removed: $tagType\n";
			$tagType =~ s/"//g;
		}
                if ($dev_val =~ /"/) {
                        print "Alert Tag $tagName: in default value invaldid\" removed: $dev_val\n";
                        $dev_val =~ s/"//g;
                }

                # Assemble the XML file
        	$out_string .= "\"$tagName\":[\"$dev_val\",\"$tagType\"],\n";
        }
	$out_string =~ s/,\n$/\n/;
	$out_string .= "},\n\"replace\":{\n";

        # Now print out all tags
        foreach my $tag_holder (@xml_tags) {
                $tagCount++;

                # Get all the XML data of one tag
                $tagName = get_node_content($tag_holder, "tagName");
                my @oldTags = get_node_content_array($tag_holder, "oldTagName");

                # Assemble the XML file
                if (!($oldTags[0] eq "")) {
                        foreach $oldTagName (@oldTags) {
                                $out_string .= "\"$oldTagName\":\"$tagName\",\n";
                        }
                }
        }
        $out_string =~ s/,\n$/\n/;
        $out_string .= "},\n" . attach_to_p3p_json() . "}\n";

        # Write the files to the disk
        my $output_file = $output_folder. "default_settings.json";
        string2file($output_file, $out_string);

        print "Printed $tagCount Tags in default_settings.json\n";

        return 0;
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


###############################################
# creates the readme.htm and manual.html file #
###############################################
sub createReadmeHtml {
	# Create a Index
	my $html_string = "<h2>CONTENTS</h2>";
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
			$html_string .= "<h2><a id=\"$textblock_holder\">$chapterCount. ";
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

        # Prepare the strings for the files
        my $html_man = html_get_header($scriptP3ManualTit);

        # Create a main title
        $html_man .= "<h1>$scriptP3ManualTit</h1>\n";

	# Add the content
        $html_man .= $html_string;
	
	# Finish the strings for the files
	$html_man .= html_get_footer();
	
	$html_man =~ s/<br \/>/<br>/g;
	$html_man =~ s/<link>(.*?)<\/link>/<a href=\"$1\">$1<\/a>/g;
	$html_man =~ s/<p3t>(.*?)<\/p3t>/<a href=\"#$1\">$1<\/a>/g;
	
	# Write the files to the disk
	my $output_file = $output_folder. "primer3_manual.htm";
	string2file($output_file, $html_man);

        # Create the manual.html for the homepage
        my $html_home = "---\nlayout: default\ntitle: Manual\n---\n<div id=\"main\">\n";
        $html_home .= $html_string;
	$html_home .= "</div>\n";

        $html_home =~ s/<br \/>/<br>/g;
        $html_home =~ s/<link>(.*?)<\/link>/<a href=\"$1\">$1<\/a>/g;
        $html_home =~ s/<p3t>(.*?)<\/p3t>/<a href=\"#$1\">$1<\/a>/g;

        # Write the files to the disk
        my $web_file = $output_folder. "manual.html";
        string2file($web_file, $html_home);

	return 0;
}

########################################
# creates the primer3web_help.htm file #
########################################
sub createPrimer3webHelp {
    # Prepare the strings for the files
    my $html_string = html_get_header($scriptP3WebHelpTit);

    $html_string .= "\n\n<!-- This file was created by the documentation scripts -->\n";
    $html_string .= "<!-- Do not edit this file -->\n";
    $html_string .= "<!-- Edit the documentation XMLs instead! -->\n\n\n";

    # Create a Index
    $html_string .= "<h1>" . $scriptP3WebHelpTit . "</h1>";
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
   
    # Do some fixes
    $html_string =~ s/<a href="#PRIMER_LEFT_4[^"]+">([^<>]+)<\/a>/$1/g;
    $html_string =~ s/<a href="#PRIMER_RIGHT_4[^"]+">([^<>]+)<\/a>/$1/g;
    $html_string =~ s/<a href="#PRIMER_INTERNAL_4[^"]+">([^<>]+)<\/a>/$1/g;
    $html_string =~ s/<a href="#PRIMER_PAIR_4[^"]+">([^<>]+)<\/a>/$1/g;
 
    # Write the files to the disk
    my $output_file = $output_folder. "primer3web_help.htm";
    string2file($output_file, $html_string);

    return 0;
}

#########################################
# creates the primer3plusHelp.html file #
#########################################
sub createPrimer3PlusHelp {
    # Prepare the strings for the files
    my $final_html_string = cgi_get_header($scriptP3PlusHelpTit);


    # Create a Index
    my $html_string .= "<h2>Index of contents</h2>";
    my $chapterCount = 0;
    $html_string .= "<p>\n";
    foreach my $textblock_holder (@textblocksPrimer3PlusHelp) {
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
            $html_string .= "<h2><a id=\"$textblock_holder\">$chapterCount. ";
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
        if ($textblock_holder eq "p3pTags") {
            $html_string =~ s/\n$//;
            $html_string .= printTable("P3P_");
            $html_string .= printTags("P3P_");
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

    # Replace the backslashes by the number code
    $final_html_string =~ s/\\p/&#92;p/g;
    $final_html_string =~ s/\\</&#92;</g;
    $final_html_string =~ s/\\\\\\/&#92;&#92;&#92;/g;

    # Write the files to the disk
    my $output_file = $output_folder. "primer3plusHelp.html";
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
	my $output = "<table class=\"p3p_tab_help_table\" style=\"text-align: left; width: 800px; border: 1px;\">\n";

	my $tagCount = 0;
	my @tags;
	my @to_use_tags;
	my $tagName;

	if ($text eq "output"){
		@tags = @outTagTags;
        } elsif ($text eq "P3P_") {
		@tags = @p3pTagTags;
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
	my $titel = shift;
	$titel =~ s/PRIMER3/Primer3/g;
        $titel =~ s/PLUS/Plus/g;
        $titel =~ s/WEB/Web/g;
        $titel =~ s/RELEASE/Release/g;
        $titel =~ s/MANUAL/Manual/g;
        $titel =~ s/HELP/Help/g;
	my $html = qq{<!doctype html>
<html lang="en">
<head>
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  <meta name="viewport" content="width=1034, initial-scale=1.0">
  <title>$titel</title>
  <style>
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
  .p3_prop {
    font-family: monospace;
    white-space: pre;
    margin: 1em 0;
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
    my $html = qq{<!doctype html>
<html lang="en">

<head>
  <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  <meta name="viewport" content="width=1034, initial-scale=1.0">
  <meta name="description" content="The Help section explains all Primer3 and Primer3Plus tags and provides information on the primer selection behind the scenes.">
  <title>Primer3Plus - Help</title>
  <link rel="stylesheet" href="static/css/primer3plus.css">
  <link rel="canonical" href="https://www.primer3plus.com/primer3plusHelp.html" />
</head>

<body>
  <div class="p3p_page">
    <div class="p3p_top_bar">
      <table>
        <colgroup>
          <col style="width: 60%" class="p3p_blue">
          <col style="width: 20%" class="p3p_blue">
          <col style="width: 20%" class="p3p_blue">
        </colgroup>
        <tr>
          <td class="p3p_big_space p3p_blue" rowspan="2"><a class="p3p_top_bar_title">Primer3Plus - Help</a><br>
            <a class="p3p_top_bar_explain">pick primers from a DNA sequence</a>
          </td>
          <td class="p3p_big_space p3p_blue">
            <a style="font-weight:bold;text-decoration: none;" href="primer3plusPackage.html">More...</a>
          </td>
          <td class="p3p_big_space p3p_blue">
            <a style="font-weight:bold;text-decoration: none;" href="https://github.com/primer3-org/primer3plus">Source Code</a>
          </td>
        </tr>
        <tr>
          <td class="p3p_big_space p3p_blue">
            <a style="font-weight:bold;text-decoration: none;" href="index.html">Back</a>
          </td>
          <td class="p3p_big_space p3p_blue">
            <a style="font-weight:bold;text-decoration: none;" href="primer3plusAbout.html">About</a>
          </td>
        </tr>
      </table>
    </div>

    <div id="P3P_TAB_HELP" class="p3p_tab_page">
};

	return $html;
}

##########################
# returns the cgi footer #
##########################
sub cgi_get_footer {
	my $html = qq{    </div>

    <div class="p3p_footer_bar">
      <div class="p3p_footer_l">
        GEAR + Primer3 &#126;
        <a target="_blank" class="p3p_footer_link" href="https://www.gear-genomics.com"> Home </a> &#183;
        <a target="_blank" class="p3p_footer_link" href="https://github.com/gear-genomics"> GEAR-GitHub </a> &#183;
        <a target="_blank" class="p3p_footer_link" href="https://github.com/primer3-org"> Primer3-GitHub </a> &#183;
        <a target="_blank" class="p3p_footer_link" href="https://www.gear-genomics.com/terms"> Terms of Use </a> &#183;
        <a target="_blank" class="p3p_footer_link" href="https://www.gear-genomics.com/contact"> Contact Us </a>
      </div>
      <div class="p3p_footer_r">
        Supported by
        <a target="_blank" class="p3p_footer_link" href="https://www.embl.de">EMBL</a>
      </div>
    </div>

  </div>

</body>
</html>
};
	
	return $html;
}

sub attach_to_p3p_json {
	my $var = qq{"server_setting_files":[
{"name":"qPCR","file":"qPCR.txt"},
{"name":"Probe","file":"probe.txt"},
{"name":"P3P v.2.4.2 Def","file":"primer3plus_2_4_2_default_settings.txt"},
{"name":"P3W v0.4.0 Def","file":"primer3web_v0_4_0_default_settings.txt"},
{"name":"P3 v1.1.4 Def","file":"primer3_v1_1_4_default_settings.txt"}
],
"misspriming_lib_files":[
{"name":"HUMAN","file":"humrep_and_simple.txt"},
{"name":"RODENT_AND_SIMPLE","file":"rodrep_and_simple.txt"},
{"name":"RODENT","file":"rodent_ref.txt"},
{"name":"DROSOPHILA","file":"drosophila_w_transposons.txt"}
]
};
	return $var;
}

