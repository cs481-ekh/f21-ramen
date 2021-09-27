#!/bin/bash
echo "Running all tests..."

flutter test
if [ "$?" -ne "0" ]; then
	  echo "Not all tests ran successfully!"
	  exit 1
fi
echo "All tests ran successfully."
exit 0