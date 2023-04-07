#!/bin/bash

#Script usage
usage(){
	echo "Usage: ArchiveToolKit [OPTION]... DIRECTORY|ARCHIVE"
	echo -e "\nA handy script for managing (compressing, decompressing, listing, encrypting) your archives."
	echo -e "\nOptions:"
	echo -e "  -c compression_algorithm    Compress a directory using a specific algorithm"
	echo -e "  -d decompression_algorithm  Decompress an archive using a specific algorithm"
	echo -e "  -e [NO_ARGS]	      	      Encrypt the archive using AES256 symmetric key encryption"
	echo "  Note: A decryption key will automatically be asked if the archive is encrypted."
	echo -e "\nExamples:"
	echo -e "Compression" 
	echo "  $0 directory         	 #Compress a given directory using zip which is used by default"
	echo "  $0 -c bzip2 directory       #Compress a directory using bzip2 compression algorithm"
	echo "  $0 -c bzip2 -e directory    #Compress and encrypt a directory using bzip2"
	echo -e "\nDecompression"
	echo "  $0 archive	 	 	#Decompress a given archive in parameter(no argument is required)"
	echo -e "\nEncryption"
	echo "  $0 -e archive	  	#Encrypt a given archive using the AES256 symmetric key algorithm"
	echo -e "\nListing archive content"
	echo "  $0 -l archive		#List the content of an archive (can be handy before extracting an archive)"
	echo -e "\nNotes"
	echo "	The supported compression algorithms are: zip(used by default), gzip and bzip."
	echo "	The supported decompression algorithms are: unzip(used by default), gunzip, bunzip2 and unrar."
	echo "	The supported encryption algorithm  is AES256."
}


#Encrypt a compressed archive using gpg symetric key
encrypt_archive(){
	local unencrypted_file=$1
	echo "[+] Starting encryption..."
	gpg --no-symkey-cache --cipher-algo AES256 -c "$unencrypted_file"
	if [[ $? -eq 0 ]]
	then
		echo "[+] "$unencrypted_file" successfully encrypted!"
	else
		echo "[-] "$unencrypted_file" encryption failed!"
		exit 1
	fi
	read -p "Would you like to delete the unencrypted archive '$unencrypted_file' [Yes/no]: " delete_unencrypted_archive
	if [[ $delete_unencrypted_archive == "" || $delete_unencrypted_archive =~ [yY](es)? ]]
	then
		shred -n 10 -uz $unencrypted_file
		echo "[+] $unencrypted_file deleted!"
	fi
}

#Decrypt an encrypted compressed archive using gpg symetric key
decrypt_archive(){
	local encrypted_filename=$1
	local output_filename=$2
	while true
	do
		gpg -o $output_filename -d $encrypted_filename
		if [[ $? -eq 0 ]]
		then
			echo "[+] $encrypted_filename has been successfully decrypted!"
			echo "[+] Output file: $output_filename"
			return
		else
			echo "[-] You entered a wrong key!"
			read -p "[?] Re-enter the encryption key[yes/no]: " user_choice
			if [[ $user_choice == "no" ]]
			then
				return 100
			fi
			clear
		fi
	done
}

#Function to get a compressed file extension
compression_extension(){
	case $1 in
		"zip")
			extension_found="zip";;
		"gzip")
			extension_found="gzip";;
		"bzip2")
			extension_found="bzip2";;
	esac
}

#Function to get a decompressed file extension
decompression_extension(){
	case $1 in
		"zip")
			extension_found="unzip";;
		"bz2")
			extension_found="bunzip2";;
		"gz")
			extension_found="gunzip";;
		"rar")
			extension_found="unrar";;
	esac
}

#Function for creating and compressing an archive
compress_archive(){
	local compressed_dir=$1
	local compression_algorithm=$2
	dest_dir=""
	echo "[+] Starting compression..."
	case $compression_algorithm in
		"gzip")
			dest_dir="$compressed_dir.tar.gz"
			tar -zcf "$dest_dir" $compressed_dir;;
		"bzip2")
			dest_dir="$compressed_dir.tar.bz2"
			tar -jcf "$dest_dir" $compressed_dir;;
		"zip" | "")
			dest_dir="$compressed_dir.zip"
			zip -r "$dest_dir" $compressed_dir;;
	esac
	echo "[+] $dir_basename successfully compressed!"
}

#Function for decompressing a compressed archive
decompress_archive(){
	local decompression_algorithm=$1
	local decompressed_filename=$2
	echo "[+] Starting decompression..."
	case $decompression_algorithm in
		"gunzip")
			tar -zxf "$decompressed_filename";;
		"bunzip2")
			tar -jxf "$decompressed_filename";;
		"unzip" | "")
			unzip "$decompressed_filename";;
		"unrar")
			unrar e "$decompressed_filename";;
	esac
	echo "[+] $decompressed_filename successfully decompressed!"
}

#List  an archive content
list_archive_content(){
	local archiving_algorithm=$1
	local archive_name=$2
	echo "[+] Listing $archive_name content..."
	case $archiving_algorithm in
		"zip")
			unzip -l $archive_name;;
		"gz")
			tar -ztvf $archive_name;;
		"bz2")
			tar -jtvf $archive_name;;
		"rar")
			unrar l $archive_name;;
	esac	
}

#Decompression error message
decompression_error_message(){
	local filename=$1
	echo "[-] ${filename##*.}: Unknown format specified!"
	echo "Supported file formats for decompression are: .zip, .gz, .bz2 and .rar"
	echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
}

#Compression error message
compression_error_message(){
	local compression_algorithm=$1
	echo "[-] $compression_algorithm: Unknown compression algorithm specified!"
	echo "Supported compression algorithms are: zip(default), gzip and bzip2."
	echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
}

#Main function
main(){
	args_tab=($*)
	if [[ -z $args_tab ]]
	then 
		echo "$0: missing operand.s"
		echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
		exit 1 
	else
		dir_path=${args_tab[-1]}
       	fi
	if [[ -n $dir_path && -e $dir_path ]]
	then
		file_extension=${dir_path##*.}
		dir_basename=$(basename $dir_path)
		par_dir=$(dirname $dir_path)
		compression_extensions=("gzip" "bzip2" "zip")
		decompression_extensions=("bunzip2" "gunzip" "unrar" "unzip")
		extension_found=""
		[[ $par_dir != "." ]] && cd $par_dir
	fi
	case $# in
		1)
			if [[ $1 == '--help' || $1 == '-h' || $1 == '--usage' ]]
			then
				usage
			elif [[ -d $1 ]]
			then
				compress_archive $dir_basename
			elif [[ -f $1 ]]
			then
				decompression_extension $file_extension
				if [[ -n $extension_found ]]
				then 
					decompress_archive $extension_found $dir_basename
				elif [[ $file_extension == "gpg" ]]
				then
					echo "[+] Starting decryption..."
					output_filename=$(echo $dir_basename | cut -d . -f -3) #x.tar.gz
					decrypt_archive $dir_basename $output_filename
					if  [[ $? == 100 ]]
					then
						echo "[-] Decryption failed!"
						echo "[!] Exiting the script..."
						sleep 2
						exit 1
					fi
					output_file_extension=${output_filename##*.}
					decompression_extension $output_file_extension
					if [[ -n $extension_found ]]
					then
						decompress_archive $extension_found $output_filename
					else
						decompression_error_message $output_filename
					fi
				else
					decompression_error_message $1
					exit 1
				fi
			else
				echo "[-] $1: Incorrect argument specified!"
				echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
				exit 1
			fi
			;;
		2)
			if [[ $1 == "-e" && -f $2 ]]
			then
				encrypt_archive $2
			elif [[ $1 == "-l" && -f $2 && $file_extension != "gpg" ]]
			then
				decompression_extension $file_extension
				if [[ -n $extension_found ]]
				then
					list_archive_content $file_extension $2
				else
					compression_error_message $2
				fi
			elif [[ $file_extension == "gpg" ]]
			then
				echo "[!] $2 is encrypted! What do you expect to see -_-'"
				exit 1
			elif [[ ! -f $2 ]]
			then
				echo "[-] $2 must be an archive see that you specified '-l' flag!"
				exit 1
			else
				echo "[-] Incorrect argument specified!" 
				echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
				exit 1
			fi
			;;
		3) 
			compression_extension $2
			if [[ $1 == "-c" && -n $extension_found && -d $3 ]]
			then
				compress_archive $dir_basename $extension_found
			else
				if [[ $1 != "-c" ]]
				then
					echo "[-]$1: Wrong argument specified (must be '-c')"
				elif [[ -z $extension_found ]]
				then
					compression_error $2
				elif [[ $1 == "-c" && ! -d $3 ]]
				then
					echo "$3 must be a directory see that you specified '-c' option"
				fi
				exit 1
			fi	
			;;
		4)
			compression_extension $2
			if [[ ($1 == "-c" && -n $extension_found  && $3 == "-e" && -d $4) ]]
			then
				compress_archive $dir_basename $extension_found
				encrypt_archive $dest_dir
			else
				if [[ $1 != "-c" || $3 != "-e" ]]
				then
					echo "[-] Wrong argument specified (first option must be '-c' and the second one must be '-e')"
				elif [[ -z $extension ]]
				then
					echo "[-] Either $2 extension does not exist or it is not supported by the script!"
				        echo "[!] Make sure to use the supported extensions available in the manual"
				elif [[ ! -d $4 ]]
				then
					echo "[!] See that you used '-c', $4 must be a directory!"
				fi
			fi
			;;			
		*)
			echo "[!] You cannot specify more than 4 arguments!"
			echo "Try '$0 -h', '$0 --help' or '$0 --usage' for more information."
			exit 1
			;;
	esac
}

main $@
