#!/bin/bash

# This script helps to automatically click profiles on Pairs and
# therefore, increase the change of your profile being viewed by others.

# Preparations:
# The script depends on `xdotool` to manipulate the mouse and keyboard.
# To install `xdotool`, please run
# $ sudo apt install xdotool

# The coordinates used in this script was gotten from 4K resolution.
# If you have a different resolution, please find the coordinates for your
# resolution by using
# $ xdotool getmouselocation

# How to use:
# 1. login into your Pairs account
# 2. (optional) set your search preference
# 3. leave the Pairs page on search 
# 4. MAKE SURE IT IS THE PAGE ON THE TOP
# 5. run this script in a terminal

# Please note that Pairs has a mechanism to have limited number of
# next you can click.

set -aux

# Number of repeats of the click scroll down loop
REPEATS=10
# Number of clicks/candidates for each iteration.
# Having a large number reduces the chance of clicking on the fake links
CLICKS_PER_ITER=100
# Delay in seconds per click to prevent server side detection.
# We need this anyway since pairs pages are quite slow
DELAY_PER_CLICK=1
# Additional random delay in seconds per click to prevent
# server side detection.
DELAY_PER_CLICK_RAN=1
# Numbers of scroll needed to move one row of candidates, the number
# depends on the resolution.
SCROLL_PER_ROW=5
# Numbers of candidates per row. The number is fixed in Pairs.
CAND_PER_ROW=5
# Delay in milliseconds per scroll, since the page is quite slow
SCROLL_DOWN_DELAY=50
# Number of scroll needed.
# It is automatically calculated.
# Basically users do not need to change this value
SCROLL_DOWN_NUM=$((SCROLL_PER_ROW * CLICKS_PER_ITER / CAND_PER_ROW))

SEARCH_URL="https://pairs.lv/search"
USER_PROFILE_PREFIX="https://pairs.lv/user/profile/"

# The total amount of candidates to be clicked is
# REPEATS * CLICKS_PER_ITER

function click_next_loop()
{
    # move to next arrow
    # when the resolution changes, the coordinates change
    xdotool mousemove 2331 1154
    # clicks
    for((j=1;j<=${CLICKS_PER_ITER};j++))
    do
        xdotool click 1
        sleep $((DELAY_PER_CLICK + RANDOM % DELAY_PER_CLICK_RAN))
    done
}

function scroll_down()
{
    local scroll_down_num=$1
    # sleep to make sure the close button is shown
    sleep 1
    # close the profile window
    xdotool mousemove 1436 213
    xdotool click 1
    # sleep to make sure the window is closed
    sleep 1

    # scroll down the page to new candidates
    # use the wheel down
    xdotool click --delay ${SCROLL_DOWN_DELAY} --repeat ${scroll_down_num} 5
}

function find_chrome()
{
    window_id=$(xdotool search --onlyvisible --class Chromium)
    xdotool windowactivate ${window_id}
}

function get_url()
{
    # move to address bar
    xdotool mousemove 752 140
    xdotool click 1
    xdotool key ctrl+a
    sleep 1
    xdotool key ctrl+c
    echo $(xclip -o)
}

function make_sure_search_page()
{
    loop_id=$1

    current_url=$(get_url)
    if [[ ${SEARCH_URL} != ${current_url} ]] && [[ ${current_url} != ${USER_PROFILE_PREFIX}* ]]
    then
        echo "the page has been changed to " ${current_url}
        # reload the address
        xdotool type ${SEARCH_URL}
        xdotool key Return
        # wait for the page to reload
        sleep 5

        # scroll down
        scroll_down $((SCROLL_DOWN_NUM * loop_id))
    fi
}

function click_first_person()
{
    xdotool mousemove 1640 477
    xdotool click 1
    sleep 3;
}

function open_profile()
{
    local need_scroll_down=$1
    local loop_id=$2

    current_url=$(get_url)
    case ${current_url} in
        ${SEARCH_URL} )  
            if [[ ${need_scroll_down} -ne 0 ]]
            then
                scroll_down $((SCROLL_PER_ROW - 1))
            fi
            click_first_person
            open_profile 1 ${loop_id};;
        ${USER_PROFILE_PREFIX}* ) ;;
        * ) make_sure_search_page ${loop_id}; scroll_down $((SCROLL_PER_ROW - 1)); click_first_person; open_profile 0 ${loop_id};;
    esac
}

# switch to chrome
find_chrome
make_sure_search_page 0

# start clicking
for((i=0;i<${REPEATS};i++))
do
    open_profile 0 i
    make_sure_search_page i
    click_next_loop
    scroll_down ${SCROLL_DOWN_NUM}
done
