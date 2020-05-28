#!/usr/bin/env python3
'''
Tested with python 3.7
'''
import os, sys, argparse
from time import perf_counter
import uuid
import random
import threading

NUGGET_BANNER = r'''
 _                                    _   
(_) ___  _ __  _   _  __ _  __ _  ___| |_ 
| |/ _ \| '_ \| | | |/ _` |/ _` |/ _ \ __|
| | (_) | | | | |_| | (_| | (_| |  __/ |_ 
|_|\___/|_| |_|\__,_|\__, |\__, |\___|\__|
                     |___/ |___/              
'''

def getArguments():
    '''
    Parses commandline arguments, the following flags exists:
        --size
    '''
    argparser = argparse.ArgumentParser(description='IONugget arguments')
    argparser.add_argument('-s',
                            '--size',
                            required=False,
                            action='store',
                            type=int,
                            default=128,
                            help="Size of the file to be written")
    argparser.add_argument('-t',
                            '--threads',
                            required=False,
                            type=int,
                            default=1,
                            help="Number of threads")
    argparser.add_argument('-o',
                            '--output',
                            required=False,
                            action='store',
                            type=str,
                            default="/tmp/result",
                            help="Output folder path")
    argparser.add_argument('-p',
                            '--print',
                            required=False,
                            action='store',
                            type=bool,
                            default=True,
                            help="Console output")
    return argparser.parse_args()

class IOTest:
    '''
    Class contains all methods needed to run a IO test
    '''
    def __init__(self, fileSizeMb, id, outfolder, cprint):
        self.tempFile = "/tmp/test" + str(id)
        self.permission = 0o777
        self.wBlockSizeKb = 1024
        self.rBlockSizeKb = 512
        self.id = id
        self.cprint = cprint
        self.outfolder = outfolder
        self.fileSizeMb = fileSizeMb
        self.wCount=int((self.fileSizeMb * 1024) / self.wBlockSizeKb)
        self.rCount=int((self.fileSizeMb * 1024 * 1024) / self.rBlockSizeKb)

    def run(self):
        writeRes = self.writeTestFile(self.wBlockSizeKb * 1024, self.wCount)
        readRes = self.readTestFile(self.rBlockSizeKb, self.rCount)
        
        writeTime = sum(writeRes)
        writeAvg = (self.fileSizeMb / writeTime)
        wMax = self.wBlockSizeKb / (1024 * min(writeRes))
        wMin = self.wBlockSizeKb / (1024 * max(writeRes))
        wResStr = ('\n{} Mb written in {:.4f} s \nAVG write speed {:.4f}\n'
                    'Max speed: {:.2f} Min speed: {:.2f}'.format(
            self.fileSizeMb, writeTime, writeAvg, wMax, wMin)
        )
        readTime = sum(readRes)
        readAvg = (self.fileSizeMb / readTime)
        rMax = self.rBlockSizeKb / (1024 * 1024 * min(readRes))
        rMin = self.rBlockSizeKb / (1024 * 1024 * max(readRes))
        rResStr = ('\n{} Mb read in {:.4f} s \nAVG read speed {:.4f}\n'
                    'Max speed: {:.2f} Min speed: {:.2f}'.format(
            self.fileSizeMb, readTime, readAvg, rMax, rMin)
        )
        if self.cprint:
            print("T " + str(self.id) + " : " + wResStr + rResStr + "\n")
        outputf = 'result' + str(self.id) + ".txt"
        self.saveResults(wResStr, rResStr, self.outfolder, outputf)

    def writeTestFile(self, blockSize, blockCount):
        '''
        Writes the file to the disk, file consisting of random data
        
        return write time for each block list
        '''
        fl = os.open(self.tempFile, os.O_CREAT | os.O_WRONLY, self.permission)

        result = []
        for i in range(blockCount):
            fileBuffer = os.urandom(blockSize) # random block of data
            startTime = perf_counter()
            os.write(fl, fileBuffer)
            os.fsync(fl)
            diff = perf_counter() - startTime
            result.append(diff)

        os.close(fl)
        return result
    
    def readTestFile(self, blockSize, blockCount):
        '''
        Reads the temporary file, times the reading
        of the file until it reaches the end.

        returs read time for each block list
        '''
        fl = os.open(self.tempFile, os.O_RDONLY, self.permission)
        offsets = list(range(0, (blockCount * blockSize), blockSize))
        random.shuffle(offsets)
        
        result = []
        for i, offset in enumerate(offsets, 1):
            start = perf_counter()
            os.lseek(fl, offset, os.SEEK_SET)  # set position
            buff = os.read(fl, blockSize)  # read from position
            t = perf_counter() - start
            if not buff: break  # if EOF reached
            result.append(t)

        os.close(fl)
        os.remove(self.tempFile)
        return result
    
    def saveResults(self, writeRes, readRes, outpath, filename):
        os.makedirs(outpath, exist_ok=True) 
        output = open(outpath + "/" + filename, 'a')
        output.write(writeRes)
        output.write(readRes)
        output.write("\n")
        output.close()

    def getFilename(self):
        return str(uuid.uuid4())

def work(size, id, out, print):
    ioTest = IOTest(size, id, out, print)
    ioTest.run()

def main():
    print(NUGGET_BANNER)
    arguments = getArguments()
    threads = []
    for i in range(arguments.threads):
        t = threading.Thread(target=work, args=(arguments.size, i, arguments.output, arguments.print))
        threads.append(t)
        t.start()

if __name__ == "__main__":
    main()
