#!/usr/bin/awk -f
# Usage: ./nasdaq.awk
# Goal: using cURL fetch the HTML content.
#      Parse through each line and extract Ticker and Price from the HTML. 


BEGIN {
    # Source
    url = "https://www.nasdaq.com/"

    # Fetch the HTML content
    cmd = "curl -s " url
    while ((cmd | getline) > 0) {
        html_content = html_content $0
    }
    close(cmd)

    # Ticker and Price
    ticker_pattern = "<span class=\"symbol\">([^<]+)</span>"
    price_pattern = "<span class=\"last-sale\">([^<]+)</span>"
}

# Extract the Ticker and Price
function extract_data(line, pattern) {
    match(line, pattern, result)
    return result[1]
}

# Main
{
    # Loop through HTML content
    while (match(html_content, ticker_pattern) && match(html_content, price_pattern)) {

        # Get ticker and price
        ticker = extract_data(html_content, ticker_pattern)
        price = extract_data(html_content, price_pattern)

        print "Ticker:", ticker
        print "Price:", price
        print "-----------------------"

        html_content = substr(html_content, RSTART+RLENGTH)
    }
}