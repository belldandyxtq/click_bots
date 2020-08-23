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

# Limitations:
# Pairs has adopted some sort of protections against robots like this script.
# The one that affects this script is Pairs inserts some fake links among
# the candidates. The script can accidentally click on these links, which leads
# to a page jump, therefore, breaks the whole flow.
# One way to prevent this is to have a large `CLICKS_PER_ITER`, since you will
# not click on the links when you are doing `next`. Please note that
# Pairs also have another mechanism to have limited number of
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
SCROLL_DOWN_DELAY=1000
# Number of scroll needed.
# It is automatically calculated.
# Basically users do not need to change this value
SCROLL_DOWN_NUM=$((SCROLL_PER_ROW * CLICKS_PER_ITER / CAND_PER_ROW))

# The total amount of candidates to be clicked is
# REPEATS * CLICKS_PER_ITER

function click_next_loop()
{
    # move to next arrow
    # when the resolution changes, the coordinates change
    xdotool mousemove 2340 1144
    # clicks
    for((j=1;j<=${CLICKS_PER_ITER};j++))
    do
        xdotool click 1
        sleep $((DELAY_PER_CLICK + RANDOM % DELAY_PER_CLICK_RAN))
    done
}

function scroll_down()
{
    # close the profile window
    xdotool mousemove 1599 165
    xdotool click 1
    # sleep to make sure the window is closed
    sleep 1

    # scroll down the page to new candidates
    # use the wheel down
    xdotool click --delay ${SCROLL_DOWN_DELAY} --repeat ${SCROLL_DOWN_NUM} 5
}

function find_chrome()
{
    window_id=$(xdotool search --onlyvisible --class Chromium)
    xdotool windowactivate ${window_id}
}


# switch to chrome
find_chrome

# start clicking
for((i=1;i<=${REPEATS};i++))
do
    click_next_loop
    scroll_down
done
