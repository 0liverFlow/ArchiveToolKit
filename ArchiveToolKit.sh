#!/bin/bash

# Colors and fonts
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NO_COLOR="\e[0m"
UNDERLINE="\e[4m"

# Script usage
usage(){
	echo -e "Usage: ArchiveToolKit OPTION(S) DIRECTORY|FILE"
	echo -e "\nA handy script for managing (compressing, decompressing, listing, encrypting, decrypting) your archives."
	echo -e "\nOptions:"
	echo -e "-c [compression_algorithm] DIR	# Compress 'DIR' using 'compression algorithm' if specified. By default, it will use zip."
	echo -e "-d ARCHIVE	# Decompress an archive using a given archive."
	echo -e "-e [NO_ARGS] FILE	# Encrypt a file using the AES256 symmetric key encryption"
	echo -e "\nExamples:"
	echo -e "\n${UNDERLINE}COMPRESSION${NO_COLOR}" 
	echo "ArchiveToolKit -c mydir       	# Compress 'mydir' using zip compression algorithm"
	echo "ArchiveToolKit -c bzip2 mydir	# Compress a directory using bzip2 compression algorithm"
	echo "ArchiveToolKit -c gzip -e mydir	# Compress then encrypt a directory using gzip and AES256 respectively."
	echo -e "\n${UNDERLINE}DECOMPRESSION${NO_COLOR}"
	echo "ArchiveToolKit -d my_archive.tar.gz  # Decompress 'my_archive.tar.gz'"
	echo "NOTE: The decompression algorithm is not required."
	echo -e "\n${UNDERLINE}ENCRYPTION${NO_COLOR}"
	echo "ArchiveToolKit -e my_archive	# Encrypt 'my_archive' using the AES256 symmetric key algorithm"
	echo -e "\n${UNDERLINE}LISTING ARCHIVE CONTENT${NO_COLOR}"
	echo "ArchiveToolKit -l archive	# List an archive's content"
	echo -e "\n${UNDERLINE}${RED}NOTES${NO_COLOR}"
	echo -e "Here is a list of the supported algorithms."
	echo "-Compression algorithms: zip (default), gzip and bzip2."
	echo "-Decompression algorithms: unzip (default), gunzip, bunzip2 and unrar."
	echo "-Encryption algorithm: AES256."
}


# Encrypt a compressed archive using gpg symetric key
encrypt_file(){
	local unencrypted_file=$1
	echo "[+] Starting encryption..."
	gpg --no-symkey-cache --cipher-algo AES256 -c "$unencrypted_file"
	if [[ $? -eq 0 ]]
	then
		echo -e "${GREEN}[+]${NO_COLOR} $unencrypted_file successfully encrypted!"
	else
		echo -e "${RED}[-]${NO_COLOR} $unencrypted_file encryption failed!"
		exit 1
	fi
	read -p "Would you like to delete '$unencrypted_file' [Yes/no]: " delete_unencrypted_file
	if [[ $delete_unencrypted_file == "" || $delete_unencrypted_file =~ [yY](es)? ]]
	then
		shred -n 10 -uz $unencrypted_file
		echo -e "${GREEN}[+]${NO_COLOR} $unencrypted_file deleted!"
	fi
}

# Decrypt an encrypted compressed archive using gpg symetric key
decrypt_file(){
	local encrypted_filename=$1
	local output_filename=$2
	echo "[+] Starting decryption..."
	while true
	do
		gpg -o $output_filename -d $encrypted_filename
		if [[ $? -eq 0 ]]
		then
			echo -e "${GREEN}[+]${NO_COLOR} $encrypted_filename has been successfully decrypted!"
			echo -e "${GREEN}[+]${NO_COLOR} Output file: $output_filename"
			return
		else
			echo -e "${RED}[-]${NO_COLOR} You entered a wrong key!"
			read -p "${YELLOW}[?]${NO_COLOR} Re-enter the encryption key[yes/no]: " user_choice
			if [[ $user_choice =~ [Nn](o) ]]
			then
				return 100
			fi
			clear
		fi
	done
}

# Function to get a compressed file extension
get_file_extension(){
	input_file_extension=$(echo ${1##*.})
	case $input_file_extension in
		"zip")
			file_extension="zip";;
		"gz")
			file_extension="gzip";;
		"bz2")
			file_extension="bzip2";;
		"rar")
			file_extension="rar";;
		"gpg")	
			file_extension="gpg";;
		*)
			file_extension="";;
	esac
}

# Function for creating and compressing an archive
compress_file(){
	local directory_to_compress=$1
	local compression_algorithm=$2
	echo directory to compress is $directory_to_compress
	dest_dir=""
	echo "[+] Starting compression..."
	case $compression_algorithm in
		"gzip")
			dest_dir=$directory_to_compress.tar.gz
			tar -zcf $dest_dir $directory_to_compress;;
		"bzip2")
			dest_dir=$directory_to_compress.tar.bz2
			tar -jcf $dest_dir $directory_to_compress;;
		"zip" | "")
			dest_dir=$directory_to_compress.zip
			echo dest_dir is $dest_dir
			zip -r $dest_dir $directory_to_compress;;
	esac
	dest_dir_absolute_path=$(readlink -f $(dirname $dest_dir))
	echo "[+] $directory_to_compress sucessfully compressed!"
	echo "[+] Compressed directory saved in $dest_dir_absolute_path"
}

# Function for decompressing a compressed file
decompress_file(){
	local compression_algorithm=$1
	local compressed_filename=$2
	local output_filename=${compressed_filename%.*}
	echo "[+] Starting decompression..."
	case $compression_algorithm in
		"gzip")
			if [[ $compression_algorithm == *.tar.gz ]]
			then
				tar -zxf "$compressed_filename" -C $file_parent_directory
			elif [[ $compression_algorithm == *.gz ]]
			then
				gunzip $compressed_filename > "$file_parent_directory/$output_filename" 
			fi
			;;
		"bzip2")
			if [[ $compression_algorithm == *.tar.bz2 ]]
			then
				tar -jxf "$compressed_filename" -C $file_parent_directory
			elif [[ $compression_algorithm == *.bz2 ]]
			then
				bunzip $compressed_filename > "$file_parent_directort/$output_filename"
			fi
			;;

		"zip" | "")
			unzip "$compressed_filename" -d $file_parent_directory;;
		"rar")
			unrar x "$compressed_filename" $file_parent_directory;;
	esac
	echo "[+] $compressed_filename successfully decompressed!"
	echo "[+] Decompressed file saved in $(readlink -f $file_parent_directory)"
}

# List  an archive content
list_archive_content(){
	local compression_algorithm=$1
	local compressed_filename=$2
	echo "[+] Listing $compressed_filename content..."
	case $compression_algorithm in
		"zip")	
			unzip -l $compressed_filename;;
		"gzip")

			if [[ $compressed_filename == *.tar.gz ]]
			then
				tar -ztvf $compressed_filename
			else
				gzip -l $compressed_filename
			fi
			;;
		"bzip2")

			if [[ $compressed_filename == *.tar.bz2 ]]
			then
				tar -jtvf $compressed_filename
			else
				bzip2 -cd $compressed_filename | tar -tvf -
			fi
			;;
		"rar")
			unrar l $compressed_filename;;
	esac	
}

# Decompression error message
decompression_error_message(){
	local filename=$1
	echo -e "${RED}[-]${NO_COLOR} ${filename##*.}: Unsupported file format specified!"
	echo "Supported file formats for decompression are: .zip, .gz, .bz2 and .rar"
	echo "Enter 'ArchiveToolKit --help' or 'ArchiveToolKit --usage' for more information."
}

# Compression error message
compression_error_message(){
	local compression_algorithm=$1
	echo -e "${RED}[-]${NO_COLOR} $compression_algorithm: Unknown compression algorithm specified!"
	echo "Supported compression algorithms are: zip(default), gzip and bzip2."
	echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
}

# Main function
main(){
	args_tab=("$@")
	#echo ${args_tab[@]}
	if [[ -z $args_tab ]]
	then 
		echo "ArchiveToolKit: Missing arguments!"
		echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
		exit 1 
	else
		file_to_compress=$(echo ${args_tab[-1]} | sed 's/\/$//')
		
       	fi
	if [[ -n $file_to_compress && -e $file_to_compress ]]
	then
		file_basename=$(basename $file_to_compress)
		file_parent_directory=$(dirname $file_to_compress)
	fi
	case $# in
		1)
			if [[ $1 == '--help' || $1 == '-h' || $1 == '--usage' ]]
			then
				usage
			else
				echo "[-] $1: Incorrect argument specified!"
				echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
				exit 1
			fi
			;;
		2)
			if [[ $1 == "-c" && -d $2 ]]
			then
				compress_file $2
			elif [[ $1 == "-d" && -f $2 ]]
			then
				get_file_extension $2
				if [[ -n $file_extension && $file_extension != "gpg" ]]
				then
					decompress_file $file_extension $2 
				elif [[ $file_extension == "gpg" ]]
				then
					output_filename=$(echo ${2%.*})
				       	echo $output_filename	

					decrypt_file $2 $output_filename
					if  [[ $? == 100 ]]
					then
						echo "[-] Decryption failed!"
						echo "[!] Exiting the script..."
						sleep 2
						exit 1
					fi
					# The instruction below returns the file extension	
					output_filename_extension=${output_filename##*.}
					get_file_extension $output_filename_extension
					if [[ -n $file_extension ]]
					then
						decompress_file $file_extension $output_filename
					else
						decompression_error_message $output_filename
					fi
				elif [[ $1 == "-d" && ! -n $file_extension ]]
				then
					echo -e "${RED}[-]${NO_COLOR} Unsupported file format!"
					usage
				elif [[ $1 == "-c" && ! -d $2 ]]
				then
					echo "${RED}[-]${NO_COLOR} $2 must be a directory!"
				fi
			elif [[ $1 == "-e" && -f $2 ]]
			then
				encrypt_file $2
			elif [[ $1 == "-l" && -f $2 ]]
			then
				get_file_extension $2
				if [[ -n $file_extension && $extension_found != "gpg" ]]
				then
					list_archive_content $file_extension $2
				else
					echo "${RED}[-]${NO_COLOR} $2: Incorrect argument specified!" 
					usage 
					exit 1
				fi
			fi
			;;
		3) 
			get_file_extension $2 
			# $2 represents the compression algorithm specified by the user
			if [[ $1 == "-c" && -n $file_extension && -d $3 ]]
			then
				compress_file $file_to_compress $file_extension
			elif [[ $1 == "-c" && $2 == "-e" && -d $3 ]]
			then
				compress_file $file_to_compress
				encrypt_file $dest_dir
			elif [[ -z $file_extension ]]
			then
				compression_error_message $2
			elif [[ ! -d $3 ]]
			then
				echo -e "${RED}[-]${NO_COLOR} $3 does not exist!"
			else
				usage
				exit 1
			fi	
			;;
		4)
			get_file_extension $2
			if [[ $1 == "-c" && -n $file_extension  && $3 == "-e" && -d $4 ]]
			then
				compress_file $file_to_compress $file_extension
				encrypt_file $dest_dir
			elif [[ -z $file_extension ]]
			then
				compression_error_message $2
			elif [[ ! -d $4 ]]
			then
				echo -e "${RED}[-]${NO_COLOR} $4 does not exist!"
				echo -e "${RED}[-]${NO_COLOR} Syntax Error: Incorrect command_"
				usage
				exit 1
			fi
			;;			
		*)
			echo -e "${RED}[-]${NO_COLOR} Syntax Error: Incorrect command!"
			usage
			exit 1
			;;
	esac
}

main $@
