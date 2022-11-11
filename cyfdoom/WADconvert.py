print("This script converts WADs into a more readable format(UTF-8 instead of raw data) for CYF.")

from pathlib import Path

pathToWADs = Path('\\'.join(__file__.split('\\')[:-1]) + "\\WADs\\")
pathToConvertedWADs = Path(pathToWADs, "Converted")

WADFiles = []

for item in pathToWADs.iterdir():
    if not item.is_file():
        continue
    with open(item, 'rb') as file:
        WADIdentification = file.read(4)
        if WADIdentification == "IWAD".encode("latin-1") or WADIdentification == "PWAD".encode("latin-1"):
            WADFiles.append(item)

print("""WADs identified in "WADs" folder:""")
for i in range(len(WADFiles)):
    print(i, WADFiles[i].name)

inputString = "Please type in the corresponding number or name to convert WAD: "
retry = True
WADPath = None
while retry:
    WADPath = input(inputString)
    if WADPath.isnumeric():
        try:
            WADPath = WADFiles[int(WADPath)]
            retry = False
        except:
            inputString = "No such key exists, please try again: "            
    else:
        WADPath = Path(pathToWADs, WADPath)
        if WADPath.exists():
            retry = False
        else:
            inputString = "No such WAD exists, please try again: "

proceed = True
convertedWADPath = Path(pathToConvertedWADs, WADPath.name)
if convertedWADPath.exists():
    proceed = input("This WAD appears to already have a converted version, this script will overwrite it, do you wish to proceed?(Y/n)\n").lower() == 'y'
if not proceed:
    print("WAD not converted, exiting script.")
    exit()
with open(WADPath, "rb") as WADFile:
    with open(convertedWADPath, 'w', encoding = "UTF-8", newline='\n') as outFile:
        outFile.write(WADFile.read().decode("latin-1"))
        print("WAD converted, exiting script.")