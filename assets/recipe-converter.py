import sys

basename = "Recipes"

tab = '  '

columns = {
    "result":0,
    "ing1":3,
    "ing2":4,
    "combiner":6
}

def writei(file, line, ind):
    file.write(tab*ind + line + '\n')


def open_output(force):
    filename = basename+'.json'
    if not force:
        file_exists = True
        try:
            outfile = open(filename, 'r')
        except OSError:
            file_exists = False
        if file_exists:
            print("Error: "+filename+" already exists. Use -f to overwrite.")
            return None

    outfile = open(filename, 'w')
    return outfile


def process_line(line, file):
    components = line.split(',')
    ing1 = components[columns['ing1']].replace(' ','')
    ing2 = components[columns['ing2']].replace(' ','')
    result = components[columns['result']].replace(' ','')
    combiner = components[columns['combiner']].replace(' ','')

    writei(file, '\"'+ing1+'+'+ing2+'\": {', 1)
    writei(file, '\"result\": \"'+result+'\",', 2)
    writei(file, '\"combiner\": \"'+combiner+'\"', 2)
    writei(file, '},', 1)


def process_csv():
    # Check for filename
    if len(sys.argv) < 2:
        print("Error: No file supplied.")
        return
    filename = sys.argv[1]

    # Check file type
    extension = filename.split('.')[-1]
    if extension != "csv":
        print("Error: Supplied file is not a .csv")
        return

    # Check command line options
    force = False
    if len(sys.argv) > 2 and sys.argv[2]=='-f':
        force = True

    # Open input file
    try:
        infile = open(filename, 'r')
    except IOError:
        print("Error: File could not be read.")
        return

    # Open outut file
    outfile = open_output(force)
    if outfile is None:
        return

    # Read Lines
    lines = infile.readlines()

    # Reformat and write to output
    writei(outfile, '{', 0)
    for line in lines:
        process_line(line, outfile)
    writei(outfile, '}', 0)


if __name__ == "__main__":
    process_csv()
