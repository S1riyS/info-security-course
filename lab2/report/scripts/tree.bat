mkdir D:\lab2\NOACCESS
mkdir D:\lab2\acc
mkdir D:\lab2\fullctl
mkdir D:\lab2\special
mkdir D:\lab2\owned
mkdir D:\lab2\takeown
mkdir D:\lab2\bin\tools
echo rule1> D:\lab2\NOACCESS\README.TXT
echo rule2a> D:\lab2\acc\accumulate.txt
echo rule2b> D:\lab2\acc\denied.txt
echo rule3a> D:\lab2\fullctl\locked.txt
echo rule3b> D:\lab2\special\locked.txt
echo note> D:\lab2\notes.log
copy C:\Windows\System32\hostname.exe D:\lab2\bin\app.exe
copy C:\Windows\System32\whoami.exe D:\lab2\bin\tools\util.exe
