#!/bin/bash
find . -mtime -1 -name \*.txt | tar -cvf bbb.tar -T -
