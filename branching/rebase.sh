#!/bin/bash
# display command line options

count=1
for param in "$@"; do
<<<<<<< HEAD
<<<<<<< HEAD


=======
>>>>>>> 265518d (git-rebase 1)
=======
    echo "Next parameter: $param"
>>>>>>> 9cfe9aa (git-rebase 2)
    count=$(( $count + 1 ))
done

echo "====="
