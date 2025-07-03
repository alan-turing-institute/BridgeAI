#!/usr/bin/env python3
import argparse
import calendar
from datetime import datetime
from dateutil.relativedelta import relativedelta

# Previously this offset the timings for the month after next so I've changed it so its not offeset anymore by switching the default to 1 
parser = argparse.ArgumentParser()
parser.add_argument(
    "number",
    type=int,
    choices=[1, 2, 3, 4, 5]
)
parser.add_argument(
    "--month-offset",
    type=int,
    default=1
)
clargs = parser.parse_args()

cal = calendar.Calendar()
today = datetime.today()

target = today + relativedelta(months=clargs.month_offset)
target_year, target_month = target.year, target.month

# Get date of every Thursday in the month
thursdays = [
    day for day in cal.itermonthdates(target.year, target.month)
    if day.weekday() == calendar.THURSDAY
    if day.month == target.month
]
if clargs.number <= len(thursdays):
    thursday = thursdays[clargs.number-1]
    print(f"{thursday.strftime('%Y-%m-%d')}")
