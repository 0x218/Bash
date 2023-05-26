# file: lookup
# searches for an item by name using an associative array

awk '
  BEGIN { FS= ", " }

        { items[$1] = $2 } # key is item name, value is price 

  END   { 
          printf "Enter item name: "
          while ( getline name < "/dev/tty" ) {
            print "Price of " name " is " items[name]
            printf "Enter item name: "
          }
        }
  ' "$1"
