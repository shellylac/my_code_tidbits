#----
# Find and Remove files by name 
find directory/ -type f -name '*_name_*.txt' -exec rm -f {} \;

#--------------
# Display every line but first
sed -n '1!p'

#--------
#list files by search for filename
list_of_files=$(ls path | grep "filename.sh")

#--------
#Find all files with particular name in multiple directories
directory_filelist=$(ls -d /top_directory/*/*/event_medissue.tsv)

#--------
#Delete the header row
sed -i '1d' $top_folder_path/4844_alleids.txt

#--------
#Simple for loop structure 
for VARIABLE in 1 2 3 4 5 .. N
do
  command1
  command2
done

for file in ls *.xml
do
  file -i $file
done

#--------
#Remove any blank lines
sed -i '/^$/d' file

#--------
#Search for blank lines in csv field #12
awk -F, '$12==""' field

#================
#check whether there is overlap in column names between two files:
grep -xF -f file1.txt file2.txt

#-----------------
#This line gives me the lines in file1 that don't match (based on id columns) file2
awk -F '\t' 'NR==FNR {exclude[$1$2$3];next} !($1$2$3 in exclude)' file1_id_col file2 

#-----------------
#add a concatenated field (made up of 1st 3 columns)
awk -F'\t' -vOFS='\t' '{ $(NF+1)=$1$2$3 ; print}' file

#============Print the text that follows a particular string (in this case 'charset=')
sed -n -e 's/^.*charset=//p'

#--------
# Search through multiple strings in a text file one at a time and output in order

while read ptn; do grep $ptn file; done < grepforthese.txt

# or alternative -> 
StringsToSearch=(string1 string2 string3)
for item in ${StringsToSearch[*]}
do
egrep '$item' /some/file.txt
done

#--------
#Count number of fields in file ('|' = separator)
awk -F'|' '{print NF; exit}' file


# -----------------------------------
# ALL THINGS NON-ASCII!!
# -----------------------------------

# search for non-ascii characters in file
grep -P -n "[^\x00-\x7F]" file.txt

# list all the unique non-ascii characters in a file
grep -ohP '[^\x00-\x7F]' file1.txt | sort -u

# Replace non ascii characters in file
#Single replace
sed -i 's/µ/u/g'
sed -i 's/²/2/g'
#doc wide replace
LC_ALL=C tr -dc '\0-\177' < file > file_corrected #works
LC_ALL=C tr -dc '\0-\177' < file > file_corrected #works
cat non_ascii_test.txt |  tr -d '\200-\377'  > tr_newfile
iconv -f utf-8 -t us-ascii file > file_converted

sed i.bak 's/\²/2/g' file > file_corrected.txt #doesn't work
LANG=C sed 's/[\d128-\d255] //g' file_examples.txt > file_corrected.txt #doesn't work

# CONVERT UTF8 FILES TO ASCII CHARACTERS
  #Check if file is UTF-8 and if so then do a character convert:
  clinical_type=$(file -ib $dedupdir_path/event_clinical_newrecords.tsv | sed -n -e 's/^.*charset=//p')
  
  #clinical check
  if [ $clinical_type == "utf-8" ]
    then 
      iconv -f utf-8 -t ascii//TRANSLIT $dedupdir_path/event_clinical_newrecords.tsv > $dedupdir_path/event_clinical_newrecords_ascii.tsv
    else
      echo NOT A UTF FILE
  fi  



# Time a command and store time as variable
mytime_orig="$(time ( sql ace_gp_live < Checktime_orig.sql ) 2>&1 1>/dev/null )"
echo "Time for original scritp is $mytime_orig" > orig_time.txt


# ------- 
# Send yourself an email
# The –s flag indicates a subject line. Follow that with a list of recipients.
# The << MAIL_END part gives an in line document. Ie. everything from this point in the script until a line commencing with the word MAIL_END.


#! /bin/bash
status_num=9 #as an example
/bin/mail -s "$0 has completed" shelly.lachish@ndph.ox.ac.uk << MAIL_END
Hi Shelly
$0 has completed with status $status_num
MAIL_END

# -------
# count all lines in all files in a directory
find dir_path/* -type f -name 'filename*.tsv' -exec wc -l {} +

##rename multiple files replacing part of a file name
folder_list=$(ls -d file_path*)
for f in $folder_list; do mv -- "$f" "${f//2020/2021}"; done

# or alternative 
for f in $folder_list; do rename '2020' '2021' $f; done

#------
# Find the max character length of column in file (in column #2)
cut -d, -f2 filename.csv | wc -L [csv file]
cut -d$'\t' -f2 filename.csv | wc -L [tab delimited file]

#------
# Find lines in file where a particular column (here e.g. 12) has a field length specification:
awk -F, 'length($12) > 3 { print }' /path/to/file.csv > bad_field_length_rows.txt

#------
# Find binary files in a folder
find public_html/* -type f -exec grep -IL . "{}" \;

#------
# Find non-binary files in a folder
find  public_html/* -type f -print | xargs file | grep ASCII | cut -d: -f1 

#------
# FIND THE MAX VALUE IN A COLUMN
awk -v max=0 '{if($1>max){want=$1; max=$1}}END{print want}' filename.txt

#------
## Count the number of files in multiple directories (need to cd to the top level you want)
du -a | cut -d/ -f2 | sort | uniq -c | sort -nr

#!/bin/bash
top_folder_path=/ukbda/bbdatan/EMIS_PROCESSING/EMIS_DATA/DEDUPLICATED_DATA
patient_file_list=$(ls $top_folder_path/*/patient*)

#----------
# Match Pseudo_ids to filepaths
# awk -v option allows to define variables
#count=0
for file in $patient_file_list
do
  #count=$[count + 1]
  file_path=$(dirname $file)
  echo $file_path
  file_name=$(basename $file .tsv)
  echo $file_name
  awk -v var=$file_path 'BEGIN{FS="\t"}{ print $3  "\t" var}' $file | sed -n '1!p' > /ukbda/bbdatan/temp.txt
  awk -v var=$file_name 'BEGIN{FS="\t"}{ print $1 "\t" $2  "\t" var}' /ukbda/bbdatan/temp.txt >> /ukbda/bbdatan/pseudo_id_details.txt
  #if [ $count -eq 1 ]; then break; fi
done


#-----
#Find and store extract_date from SQL database as bash variable
extract_date=`echo "select max(extract_date) from table where condition = 1;\\g\\q" | sql -S ace_gp_live`

#------
# Extract patient keys (first column - pat_guid - of each patient.tsv file)
for file in $filelist 
do 
 path=$(dirname $file) 
 dirname=$(basename $path)
 cut -d$'\t' -f 1 < "$file" > "$archive_directory/patient_key_$dirname.txt"
done

#------
# Extract first 3 columns of each file (tab separated)
cut -d$'\t' -f 1-3 < file > outfile.txt

#----
# Merge all the respective .txt files (with name pattern) into one file.
#This merges the files and saves them as tab-delimited txt
awk 'FNR==1 && NR!=1{next;}{print}' /directory/name_pattern_*.txt > /directory/all_patient_keys.txt

#----
# REMOVE any duplicates from files
# -u = unique / -T sets a temp directory which can be necessary for memory/space issues
# -o = output file to save to
sort -uT /user/bbdatan/Temp $directory/file.txt -o $directory/file_unique.txt
