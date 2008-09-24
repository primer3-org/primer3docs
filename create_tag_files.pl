#!/usr/bin/perl -w

# This script requires the XML-LibXML extention by Christian Glahn from cpan

use strict;
use Cwd;
use XML::LibXML;
use File::Copy;

my $input_file = "primer3_tag_definitions.xml";
my $output_folder = cwd.'/script_output/';

print"start processing\n";

# Open the xml File
my $parser = XML::LibXML->new();
my $tree = $parser->parse_file($input_file);
my $root = $tree->getDocumentElement;

# Get the root element
my $root_name = $root->nodeName;

# Check the root element to be sure to have the right file
if ($root_name ne "tagList") {
	print "Error: $root_name is not \"tagList\"\n";
	exit;
}

# Read all tags into an array
my @xml_tags = $root->getElementsByTagName('tag');

# Prepare the strings for the files
my $html_string = html_get_header();
my $txt_string = "";
my $xml_string = xml_get_header();

# Now print out all tags
my $tagCount = 0;
foreach my $tag_holder (@xml_tags) {
	$tagCount++;
	
	# Get all the XML data of one tag
	my $tagName = get_node_content($tag_holder, "tagName");
	my $dataType = get_node_content($tag_holder, "dataType");
	my $default = get_node_content($tag_holder, "default");
	my $description = get_node_content($tag_holder, "description");


	# Assemble the html file
	$html_string .= "<h3>".$tagName."</h3>\n\n<p>(";
	$html_string .= $dataType."; default ".$default.")<br><br>\n\n";
	$html_string .= "$description</p>\n\n\n";

	# Assemble the txt file
	$txt_string .= $tagName." (".$dataType."; default ".$default.")\n\n";
	$txt_string .= "$description\n\n\n";

	# Assemble the txt file
	$xml_string .= "<tag>\n\t<tagName>".$tagName."</tagName>\n\t<dataType>";
	$xml_string .= $dataType."</dataType>\n\t<default>".$default;
	$xml_string .= "</default>\n\t<description>\n<![CDATA[";
	$xml_string .= $description."]]>\n\t</description>\n</tag>\n";
	
	
	
}
# Finish the strings for the files
$html_string .= html_get_footer();
$txt_string .= "";
$xml_string .= "</tagList>\n";


print "\nPrinted out $tagCount Tags!\n\n";
# print "$txt_string\n";
# print "$html_string\n";

# Write the files to the disk
my $output_file = $output_folder. "tag_definitions.txt";
string2file($output_file, $txt_string);

$output_file = $output_folder. "tag_definitions.htm";
string2file($output_file, $html_string);

$output_file = $output_folder. "tag_definitions.xml";
string2file($output_file, $xml_string);


print"end processing\n";









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
  <title>Primer3 - All Input Tags</title>
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

##################################
# returns the xml for the header #
##################################
sub xml_get_header {
	my $html = qq{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<tagList version="1.0">
};

	return $html;
}
