How to install and run the script
---------------------------------

Update your environment on Linux:

`sudo apt-get install libxml2-dev`

`sudo perl -MCPAN -e shell`
`install XML::LibXML`
`exit`

Update your environment on Windows:

Install: [Perl from ActiveState](https://www.activestate.com/activeperl)

Run: Perl Package Manager
Search and install: `XML-LibXML`


Run the script:

`./create_tag_files_and_docs.pl`

Guide to use Primer3 docs
-------------------------

The motivation to start this documentation script originated from the 
need to keep the readme files in Primer3 and the helpfiles in 
Primer3Web and Primer3Plus in sync. With Primer3 getting more input 
tags this also helps to keep the overview.

It works rather simple. All information is stored in XML files. Then 
a script is run which generates the html and txt files from it. This 
end up in the folder script_output. Old and tested documents are in 
reference_docs. Compare your new output to them to avoid loosing 
information or other unwanted effects.

Of course there would be better ways, but I (A. Untergasser) know perl 
and wanted fast results. That does of course not mean we should keep 
it like that for ever.

There are three xml files:

primer3_command_line.xml
A list of all possible command line flags. New flags are automatically 
added to all generated files. 

primer3_tag_definitions.xml
A list of all possible input tags. New tags are automatically added 
to all generated files.

primer3_output_tags.xml
A list of all possible output tags. New tags are automatically added 
to all generated files.

primer3_textblocks.xml
A alphabetical list of textblocks. The script reads them in and puts 
them into order. New textblocks needed to be added to the 
@textblocksOrder array to be addet to the generated files.

In the <description> field of the tags and the <text> field of the 
textblocks the following html-like elements are allowed. The script 
will remove them for the txt files and modify them for html files:

<p3_version />
	will be replaced by the version, for example 1.1.4
<p3_year />
	will be replaced by the years,
	for example: 1996,1997,1998,1999,2000,2001,2004,2006,2007,2008
<br />
	a html newline, it will be removed in txt files (not replaced 
	by a \n)
<p3t>.....</p3t>
	Will be turned into a link to the anchor. All tag descriptions 
	Are automatically anchors. Like that it will link to its 
	description (or be removed in txt files).
<link>webpage.htm</link>
	Will be turned into a www-link to webpage.htm (or be plain text 
	in txt files).

	 
