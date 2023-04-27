# ArchiveToolKit
![Bash](https://img.shields.io/static/v1?label=GNU/Linux&message=bash&color=yellow)
![Version 1.0](http://img.shields.io/badge/version-v1.0-orange.svg) ![License](https://img.shields.io/badge/license-GPLv3-red.svg) <img src="https://img.shields.io/badge/Maintained%3F-Yes-96c40f"> 
 
 ## Purpose
 ArchiveToolKit is a handy bash script that helps you manage your archive files. <br> 
With this tool, you can easily perform actions like:
- Creating and compressing an archive.
- Decompressing a compressed archive.
- Listing an archive's content before extracting it.
- Encrypting and decrypting an archive.
## Preview
<img width="1353" alt="image" src="https://user-images.githubusercontent.com/64969369/234926958-9ba29322-0de0-4648-8f17-621932a4c468.png"> <br>
## Installation & Usage
ArchiveToolKit is a script that works only on **GNU/Linux** systems.
```
git clone https://github.com/0liverFlow/ArchiveToolKit
cd ./ArchiveToolKit
```
Then you can run
```
./ArchiveToolKit -h
```
## Dependencies
```
required: tar, zip, unzip, gzip, gunzip, bzip2, bunzip2, gpg, sed, shred
```
## Notes
Here is a list of the formats supported by the script:
- Compression algorithms: **zip (used by default), gzip and bzip2**
- Decompression algorithms: **zip, gzip, bzip2, rar**
- Encryption algorithm: **AES 256**
## Examples
These are some examples that can help you better understand how ArchiveToolKit works.
### Compress a directory
<p>The following command will use <b>zip</b> to compress the specified directory. <p>
<img width="1199" alt="image" src="https://user-images.githubusercontent.com/64969369/234930514-97f23878-8e6b-45bb-92fa-f22789781ed7.png"> <br>
<p>⚠️: <b>zip</b> is used by default if no compression algorithm is specified.</p>

### Compress a directory using a specific compression algorithm
<p>In this example, we're going to compress a directory using the <b>bzip2</b> algorithm<p>
 
![image](https://user-images.githubusercontent.com/64969369/234934381-0268a335-9b24-4f16-bc71-623d87fee7f4.png)
<p>Here, you need to keep in mind that <b>bz2</b> is used to specify the <b>bzip2</b> algorithm, while  <b>gz</b> is used for the  <b>gzip</b> algorithm.</p>

### Compress and Encrypt a directory
<p>For that, you need to specify the <b>-c</b> option followed by <b>-e</b> option as follows:
 <img width="1391" alt="image" src="https://user-images.githubusercontent.com/64969369/234936055-0bdb2324-53d8-418e-9119-f6ddd011f7c9.png">
<p>As you can see, the command above first compressed then encrypted the directory specified as argument</p>
<p><b>NOTE📝:</b> It is absolutely possible to remove the compressed directory if you only want to keep the encrypted format.</p>

### Decompress a compressed archive
<p>In this example, we simply decompressed  a compressed archive using the <b>-d</b> option.</p>

<img width="1337" alt="image" src="https://user-images.githubusercontent.com/64969369/234940061-206a6ede-7f28-4d68-99b2-a2edd433f19b.png">

<p>As you can see, <b>the decompression algorithm is not required at all</b>. In fact, the script will automatically detect the algorithm type based on the file extension.</p>
<p><b>NOTE📝:</b> <b>If the archive was encrypted</b>, you would have been asked to firstly enter the decryption key before the decompression phase.</p>

### List an archive content without extracting it 
<p>Listing an archive's content before extracting it, is always a good practice see that it can allow you to have a view of what's really inside the archive.</p>

<img width="1053" alt="image" src="https://user-images.githubusercontent.com/64969369/234941788-2d075d54-970e-4800-8f4b-db19d7d4694a.png">

<p>As you can see on the screenshot above,  we got the content of <b>mydir.tar.gz</b> archive without extracting its content. <p/>
<p> Feel free to use the <b>-h</b> option to get more information about ArchiveToolKit's features 😉. <p/>
