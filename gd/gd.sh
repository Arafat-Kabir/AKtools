#!/bin/bash

#####################################################################
#  -- README --                                                     #
# This script simply selects an entry from the gdlistPath           #
# file. You need to add the following function in the .bashrc       #
# file to be able to use the gd command.                            #
#                                                                   #
# gd() {                                                            #
#     local resp=$(gd.sh $@)                                        #
#     local stat=$(echo "$resp" | head -n1)                         #
#     local info=$(echo "$resp" | tail -n +2)                       #
#     [ "$stat" = "PASS" ] && cd $(eval echo $info) || echo "$info" #
# }                                                                 #
#####################################################################

gdlistPath=~/.config/makabir/gdlist.txt
usage="gd [ list | index | substring ]"

# Handles parsing of the list file
getPathList() {
    # Filters
    local cmt1='^#'
    local cmt2='^ #'
    local emt1='^$'
    local emt2='^ $'
    local path_lines=$(cat $gdlistPath | tr -s ' ' | grep -e "$cmt1" -e "$cmt2" -e "$emt1" -e "$emt2" -v)
    local no_inline=$(echo "$path_lines" | sed 's/#.\+//')
    echo "$no_inline"
}

# Shows the path list with index
showPathList() {
    getPathList | cat -n
}

# Selects path by index
selectIndex() {
    getPathList | awk "NR==$1"
}

# Selects path by name (regexp match)
selectName() {
    getPathList | grep -i $1
}

exapandName() {
    eval echo $1
}

# select between index/name based choice
goDir() {
	input=$1
    if [[ $input =~ ^[+-]?[0-9]+$ ]]; then
        # index provided
        local match=$(selectIndex $input)
    else 
        # name provided
        local match=$(selectName $input)
    fi

    local match_cnt=$(echo "$match" | wc -l)
    if [ $match_cnt -eq 0 ]; then
        echo "FAIL"
        echo "INFO: No matches"
        exit 1
    elif [ $match_cnt -gt 1 ]; then
        echo "FAIL"
        echo "INFO: Multiple matches"
        echo "$match"
        exit 2
    elif [ ! -e $(exapandName $match) ]; then
        echo "FAIL"
        echo "$match does not exist"
        exit 3
    else
        echo "PASS"
        echo $match
    fi
}


main() {
    # default action
    [ $# -eq 0 ] && echo "FAIL" && showPathList && exit 0
    # only 1 parameter accepted
    [ $# -ne 1 ] && echo $usage
    # return the selected path for alias to handle
    goDir $1
}

main $@

