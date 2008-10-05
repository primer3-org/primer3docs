#!/usr/bin/perl -w

# This script requires the XML-LibXML extentions by Christian Glahn from cpan

use strict;
use Cwd;
use XML::LibXML;
use File::Copy;

my $tag_file = "primer3_tag_definitions.xml";
my $output_folder = cwd.'/script_output/';

print"start processing\n";

# Open the xml File
my $tagParser = XML::LibXML->new();
my $tagTree = $tagParser->parse_file($tag_file);
my $tagRoot = $tagTree->getDocumentElement;

# Get the root element name
my $tagRootName = $tagRoot->nodeName;

# Check the root element to be sure to have the right file
if ($tagRootName ne "primer3Doc") {
	print "Error: $tagRootName of $tag_file is not \"primer3Doc\"\n";
	exit;
}

# Read all tags into an array
my @xml_tags = $tagRoot->getElementsByTagName('tag');

my $tagCount = 0;
# First sort the tags alphabetically tags
my @sortedTags = sort tagSort @xml_tags;

my $readTagCount = $#sortedTags + 1;
print "Read in $readTagCount for processing...\n";

# Create the readme.txt
createReadmeTxt();
createTagDefinitionsXml();
createReadmeHtml();


print"end processing\n";






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

##########################################
# Writes a string int a File and returns #
#      0 for success                     #
#      or error message                  #
##########################################
sub string2file {
	my $file = shift;	# File Name
	my $string = shift; # String to save in
	my $error = 0;
	
	$string =~ s/<br \/>/<br>/g;

	if (open FILE, ">:utf8", $file) { 
		print FILE $string;
		close(FILE);
		
	} 
	else {
		$error = "Couldn't open $file for reading!\n";
	}

    return $error;
}


###############################
# creates the readme txt file #
###############################
sub createReadmeTxt {
	# Prepare the strings for the files
	my $txt_string = "";
	my $tagCount = 0;
	
	# Now print out all tags
	foreach my $tag_holder (@sortedTags) {
		$tagCount++;
		
		# Get all the XML data of one tag
		my $tagName = get_node_content($tag_holder, "tagName");
		my $dataType = get_node_content($tag_holder, "dataType");
		my $default = get_node_content($tag_holder, "default");
		my $description = get_node_content($tag_holder, "description");
		
		# Assemble the txt file
		$txt_string .= $tagName." (".$dataType."; default ".$default.")\n\n";
		$txt_string .= "$description\n\n\n";
	
		
	}

	# Write the files to the disk
	my $output_file = $output_folder. "readme.txt";
	string2file($output_file, $txt_string);

	print "Printed $tagCount Tags in readme.txt\n";

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
	foreach my $tag_holder (@sortedTags) {
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
# creates the readme txt file #
###############################
sub createReadmeHtml {
	# Prepare the strings for the files
	my $html_string = html_get_header();
	my $tagCount = 0;
	
	# Lets print the overview table for the HTML file
	foreach my $tag_holder (@sortedTags) {
		# Get all the XML data of one tag
		my $tagName = get_node_content($tag_holder, "tagName");
	
	
		# Assemble the html file
		$html_string .= "<a href=\"#$tagName\" style=\"font-size:0.8em\">".$tagName."</a><br>\n\n";
	
		
	}
	
	# Now print out all tags
	foreach my $tag_holder (@sortedTags) {
		$tagCount++;
		
		# Get all the XML data of one tag
		my $tagName = get_node_content($tag_holder, "tagName");
		my $dataType = get_node_content($tag_holder, "dataType");
		my $default = get_node_content($tag_holder, "default");
		my $description = get_node_content($tag_holder, "description");
	
	
		# Assemble the html file
		$html_string .= "<h3><a name=\"$tagName\">".$tagName."</a></h3>\n\n<p>(";
		$html_string .= $dataType."; default ".$default.")<br><br>\n\n";
		$html_string .= "$description</p>\n\n\n";
	
		
	}
	
	# Finish the strings for the files
	$html_string .= html_get_footer();
	
	print "\nPrinted out $tagCount Tags!\n\n";
	
	# Write the files to the disk
	my $output_file = $output_folder. "readme.htm";
	string2file($output_file, $html_string);


	print "Printed $tagCount Tags in readme.htm\n";

	return 0;
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
  <title>Primer3 - Readme</title>
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

  div#page {
  background:#FFFFFF;
  margin:25px;
  padding:0;
  text-align:left;
  width:900px;
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

