import bz2
import os


def chunkname(filecount):
    return os.path.join("/code/data/chunks", "chunk-"+str(filecount)+".xml.bz2")


def split_file(bzfile):
    pagecount = 0
    filecount = 1
    chunkfile = bz2.BZ2File(chunkname(filecount), 'w')
    chunkfile.write(str.encode('<root>'))

    for line in bzfile:
        # for first file
        if ('<mediawiki').encode() in line:
            continue
        # for last file
        elif ('</mediawiki>').encode() in line:
            chunkfile.write(str.encode('</root>'))
        else:
            chunkfile.write(line)

        if ('</page>').encode() not in line:
            continue
        pagecount += 1

        # split into 100 pages per file
        if pagecount <= 100:
            continue
        chunkfile.write(str.encode('</root>'))
        chunkfile.close()

        pagecount = 0  # RESET pagecount
        filecount += 1  # increment filename

        chunkfile = bz2.BZ2File(chunkname(filecount), 'w')
        chunkfile.write(str.encode('<root>'))

    try:
        chunkfile.close()
        print('done')
    except Exception:
        print('File already closed')


if __name__ == "__main__":
    filename = '/code/data/pages-articles-multistream.xml.bz2'
    bzfile = bz2.BZ2File(filename)
    split_file(bzfile)
